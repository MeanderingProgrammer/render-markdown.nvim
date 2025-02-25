from dataclasses import dataclass, field
from functools import cached_property
from pathlib import Path

import tree_sitter_lua
import tree_sitter_markdown
from tree_sitter import Language, Parser


@dataclass(frozen=True)
class LuaClass:
    name: str
    fields: list[str] = field(default_factory=list)

    @cached_property
    def class_name(self) -> str:
        # ---@class render.md.Init: render.md.Api                               -> Init
        # ---@class (exact) render.md.UserBufferConfig                          -> UserBufferConfig
        # ---@class (exact) render.md.UserConfig: render.md.UserBufferConfig    -> UserConfig
        return self.name.split(":")[0].split()[-1].split(".")[-1]

    @cached_property
    def is_user(self) -> bool:
        return self.class_name.startswith("User")

    def is_optional(self, field: str) -> bool:
        class_to_optional: dict[str, list[str]] = {
            "Handler": ["extends"],
            "HeadingCustom": ["icon", "background", "foreground"],
            "LinkContext": ["alias"],
            "UserCode": ["highlight_language"],
            "UserCustomCheckbox": ["scope_highlight"],
            "UserCheckboxComponent": ["scope_highlight"],
            "UserCustomCallout": ["quote_icon"],
            "UserLinkComponent": ["highlight"],
            "UserHtmlComment": ["text"],
        }

        # ---@field public extends? boolean             -> extends
        # ---@field public start_row integer            -> start_row
        # ---@field public attach? fun(buf: integer)    -> attach
        field_name = field.split()[2].replace("?", "", 1)
        return field_name in class_to_optional.get(self.class_name, [])

    def validate(self) -> None:
        for field in self.fields:
            # User classes are expected to have optional fields with no exceptions
            # Internal classes are expected to have mandatory fields with some exceptions
            optional = self.is_user or self.is_optional(field)
            message = "optional" if optional else "mandatory"
            assert ("?" in field) == optional, f"Field must be {message}: {field}"

    def to_internal(self) -> str:
        lines: list[str] = [self.name.replace("User", "")]
        for field in self.fields:
            if self.class_name == "UserConfigOverrides":
                lines.append(field.replace("?", "", 1))
            elif self.is_optional(field):
                lines.append(field)
            else:
                lines.append(field.replace("User", "").replace("?", "", 1))
        return "\n".join(lines)

    def to_str(self) -> str:
        return "\n".join([self.name] + self.fields)


INIT_LUA = Path("lua/render-markdown/init.lua")
TYPES_LUA = Path("lua/render-markdown/types.lua")
README_MD = Path("README.md")
HANDLERS_MD = Path("doc/custom-handlers.md")


def main() -> None:
    update_types()
    update_readme()
    update_handlers()


def update_types() -> None:
    classes: list[str] = ["---@meta"]
    for lua_class in get_classes():
        lua_class.validate()
        if lua_class.is_user:
            classes.append(lua_class.to_internal())
    TYPES_LUA.write_text("\n\n".join(classes) + "\n")


def update_readme() -> None:

    def wrap_setup(value: str) -> str:
        return f"require('render-markdown').setup({value})\n"

    old_config = get_code_block(README_MD, "log_level", 1)
    new_config = wrap_setup(get_default_config())
    text = README_MD.read_text().replace(old_config, new_config)

    parameters: list[str] = [
        "heading",
        "paragraph",
        "code",
        "dash",
        "bullet",
        "checkbox",
        "quote",
        "pipe_table",
        "callout",
        "link",
        "sign",
        "indent",
    ]
    for parameter in parameters:
        old_param = get_code_block(README_MD, f"\n    {parameter} = {{", 2)
        new_param = wrap_setup(get_config_for(new_config, parameter))
        text = text.replace(old_param, new_param)

    README_MD.write_text(text)


def update_handlers() -> None:
    name_lua = {lua.class_name: lua for lua in get_classes()}
    names = ["Mark", "HandlerContext", "Handler"]
    lua_classes = [name_lua[name] for name in names]

    old = get_code_block(HANDLERS_MD, lua_classes[0].name, 1)
    new = "\n".join([lua.to_str() + "\n" for lua in lua_classes])
    text = HANDLERS_MD.read_text().replace(old, new)
    HANDLERS_MD.write_text(text)


def get_classes() -> list[LuaClass]:
    lua_classes: list[LuaClass] = []
    for comment in get_comments():
        # ---@class render.md.Init: render.md.Api       -> class
        # ---@field public enabled? boolean             -> field
        # ---@alias render.md.code.Width 'full'|'block' -> alias
        # ---@type render.md.Config                     -> type
        # ---@param opts? render.md.UserConfig          -> param
        # -- Inlined with 'image' elements              -> --
        annotation = comment.split()[0].split("@")[-1]
        if annotation == "class":
            lua_classes.append(LuaClass(comment))
        elif annotation == "field":
            lua_classes[-1].fields.append(comment)
    return lua_classes


def get_config_for(config: str, parameter: str) -> str:
    lines: list[str] = config.splitlines()
    start: int = lines.index(f"    {parameter} = {{")
    for i in range(start - 1, 0, -1):
        if "--" not in lines[i]:
            start = i + 1
            break
    end: int = lines.index("    },", start)
    return "\n".join(["{"] + lines[start : end + 1] + ["}"])


def get_comments() -> list[str]:
    query = "(comment) @comment"
    return ts_query(INIT_LUA, query, "comment")


def get_default_config() -> str:
    query = """
        (assignment_statement
            (variable_list
                name: (dot_index_expression
                    field: (identifier) @name
                    (#eq? @name "default_config")
                )
            )
            (expression_list value: (table_constructor)) @value
        )
    """
    default_configs = ts_query(INIT_LUA, query, "value")
    assert len(default_configs) == 1
    return default_configs[0]


def get_code_block(file: Path, content: str, n: int) -> str:
    query = "(code_fence_content) @content"
    code_blocks = ts_query(file, query, "content")
    code_blocks = [code for code in code_blocks if content in code]
    assert len(code_blocks) == n, f"Expected {n}, Found {len(code_blocks)}"
    return code_blocks[n - 1]


def ts_query(file: Path, query: str, target: str) -> list[str]:
    tree_sitter = {
        ".lua": tree_sitter_lua,
        ".md": tree_sitter_markdown,
    }[file.suffix]

    language = Language(tree_sitter.language())
    tree = Parser(language).parse(file.read_text().encode())
    captures = language.query(query).captures(tree.root_node)

    nodes = captures[target]
    nodes.sort(key=lambda node: node.start_byte)
    texts = [node.text for node in nodes]
    return [text.decode() for text in texts if text is not None]


if __name__ == "__main__":
    main()
