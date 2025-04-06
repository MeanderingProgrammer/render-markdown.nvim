from dataclasses import dataclass, field
from pathlib import Path

import tree_sitter_lua
import tree_sitter_markdown
from tree_sitter import Language, Parser


@dataclass(frozen=True)
class LuaAlias:
    value: str
    options: list[str] = field(default_factory=list)

    def add(self, value: str) -> None:
        self.options.append(value)

    def name(self) -> str:
        # ---@alias md.mark.Line md.mark.Text[] -> md.mark.Line
        return self.value.split()[1]

    def to_str(self) -> str:
        return "\n".join([self.value] + self.options)


@dataclass(frozen=True)
class LuaClass:
    value: str
    fields: list[str] = field(default_factory=list)

    def add(self, value: str) -> None:
        self.fields.append(value)

    def exact(self) -> bool:
        return self.value.split()[1] == "(exact)"

    def name(self) -> str:
        # ---@class md.Init: md.Api                     -> md.Init
        # ---@class (exact) md.buffer.Config            -> md.buffer.Config
        # ---@class (exact) md.Config: md.buffer.Config -> md.Config
        return self.value.split(":")[0].split()[-1]

    def config(self) -> bool:
        return self.name().split(".")[-1] == "Config"

    def to_user(self) -> str:
        def user(s: str) -> str:
            return s.replace(".Config", ".UserConfig")

        lines: list[str] = [user(self.value)]
        for field in self.fields:
            field = user(field)
            name = field.split()[1]
            if not name.endswith("?"):
                field = field.replace(f" {name} ", f" {name}? ")
            lines.append(field)
        return "\n".join(lines)

    def to_str(self) -> str:
        return "\n".join([self.value] + self.fields)


def main() -> None:
    init = Path("lua/render-markdown/init.lua")
    update_types(init)
    update_readme(init)
    update_handlers()


def update_types(init: Path) -> None:
    configs = list(Path("lua/render-markdown/config").iterdir())
    configs.sort(key=str)
    files: list[Path] = [init] + configs

    classes: list[str] = ["---@meta"]
    for definition in get_definitions(files):
        if not isinstance(definition, LuaClass):
            continue
        if definition.exact() and definition.config():
            classes.append(definition.to_user())

    types = Path("lua/render-markdown/types.lua")
    types.write_text("\n\n".join(classes) + "\n")


def update_readme(init: Path) -> None:
    readme = Path("README.md")
    old_config = get_code_block(readme, "log_level", 1)
    new_config = wrap_setup(get_default(init))
    text = readme.read_text().replace(old_config, new_config)

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
        old_param = get_code_block(readme, f"\n    {parameter} = {{", 2)
        new_param = wrap_setup(get_config_for(new_config, parameter))
        text = text.replace(old_param, new_param)

    readme.write_text(text)


def wrap_setup(s: str) -> str:
    return f"require('render-markdown').setup({s})\n"


def update_handlers() -> None:
    files: list[Path] = [
        Path("lua/render-markdown/core/ui.lua"),
        Path("lua/render-markdown/lib/marks.lua"),
    ]
    name_lua = {lua.name(): lua for lua in get_definitions(files)}
    names = [
        "render.md.Handler",
        "render.md.handler.Context",
        "render.md.Mark",
        "render.md.mark.Opts",
        "render.md.mark.Line",
        "render.md.mark.Text",
    ]
    definitions = [name_lua[name] for name in names]

    handlers = Path("doc/custom-handlers.md")
    old = get_code_block(handlers, definitions[-1].value, 1)
    new = "\n".join([lua.to_str() + "\n" for lua in definitions])
    text = handlers.read_text().replace(old, new)
    handlers.write_text(text)


def get_definitions(files: list[Path]) -> list[LuaAlias | LuaClass]:
    result: list[LuaAlias | LuaClass] = []
    for file in files:
        for comment in get_comments(file):
            # ---@class md.Init: md.Api        -> class
            # ---@field enabled? boolean       -> field
            # ---@alias md.bullet.Text         -> alias
            # ---| string                      -> ---|
            # ---@type md.Config               -> type
            # ---@param opts? md.UserConfig    -> param
            # -- Inlined with 'image' elements -> --
            annotation = comment.split()[0].split("@")[-1]
            if annotation == "alias":
                result.append(LuaAlias(comment))
            elif annotation == "class":
                result.append(LuaClass(comment))
            elif annotation in ["field", "---|"]:
                result[-1].add(comment)
    return result


def get_config_for(config: str, parameter: str) -> str:
    lines: list[str] = config.splitlines()
    start: int = lines.index(f"    {parameter} = {{")
    for i in range(start - 1, 0, -1):
        if "--" not in lines[i]:
            start = i + 1
            break
    end: int = lines.index("    },", start)
    return "\n".join(["{"] + lines[start : end + 1] + ["}"])


def get_comments(file: Path) -> list[str]:
    query = "(comment) @comment"
    return ts_query(file, query, "comment")


def get_default(file: Path) -> str:
    query = """
    (assignment_statement
        (variable_list
            name: (dot_index_expression
                field: (identifier) @name
                (#eq? @name "default")))
        (expression_list value: (table_constructor)) @value)
    """
    default_configs = ts_query(file, query, "value")
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
