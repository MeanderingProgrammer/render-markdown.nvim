import re
from dataclasses import dataclass, field
from pathlib import Path
from textwrap import indent
from typing import Protocol

import tree_sitter_lua
import tree_sitter_markdown
from tree_sitter import Language, Parser


class LuaType(Protocol):
    @property
    def value(self) -> str: ...

    def add(self, value: str) -> None: ...

    def name(self) -> str: ...

    def to_user(self) -> str | None: ...

    def to_str(self) -> str: ...


@dataclass(frozen=True)
class LuaAlias:
    value: str
    options: list[str] = field(default_factory=list)

    def add(self, value: str) -> None:
        self.options.append(value)

    def name(self) -> str:
        # ---@alias md.mark.Line md.mark.Text[] -> md.mark.Line
        return self.value.split()[1]

    def to_user(self) -> str | None:
        simple = self.name().split(".")[-1]
        if simple != "Configs":
            return None

        lines: list[str] = []
        values = [self.value] + self.options
        for value in values:
            value = value.replace(".Config", ".UserConfig")
            lines.append(value)
        return "\n".join(lines)

    def to_str(self) -> str:
        return "\n".join([self.value] + self.options)


@dataclass(frozen=True)
class LuaClass:
    value: str
    fields: list[str] = field(default_factory=list)

    def add(self, value: str) -> None:
        self.fields.append(value)

    def name(self) -> str:
        # ---@class md.Init: md.Api                     -> md.Init
        # ---@class (exact) md.buffer.Config            -> md.buffer.Config
        # ---@class (exact) md.Config: md.buffer.Config -> md.Config
        return self.value.split(":")[0].split()[-1]

    def to_user(self) -> str | None:
        kind = self.value.split()[1]
        simple = self.name().split(".")[-1]
        if kind != "(exact)" or simple != "Config":
            return None

        lines: list[str] = []
        values = [self.value] + self.fields
        for i, value in enumerate(values):
            value = value.replace(".Config", ".UserConfig")
            if i > 0:
                name = value.split()[1]
                if not name.endswith("?"):
                    value = value.replace(f" {name} ", f" {name}? ")
            lines.append(value)
        return "\n".join(lines)

    def to_str(self) -> str:
        return "\n".join([self.value] + self.fields)


def main() -> None:
    root = next(Path("lua").glob("*"))
    update_types(root)
    update_readme(root)
    update_handlers(root)


def update_types(root: Path) -> None:
    files: list[Path] = [
        root.joinpath("init.lua"),
        root.joinpath("settings.lua"),
    ]

    sections: list[str] = ["---@meta"]
    for lua_type in get_lua_types(files):
        user = lua_type.to_user()
        if user is not None:
            sections.append(user)

    types = root.joinpath("types.lua")
    types.write_text("\n\n".join(sections) + "\n")


def update_readme(root: Path) -> None:
    readme = Path("README.md")
    settings = root.joinpath("settings.lua")
    old = get_code_block(readme, "log_level", 1)
    new = wrap_setup(root, get_default(root.joinpath("init.lua"), None))
    while True:
        match = re.search(r"settings\.(.*?)\.default", new)
        if match is None:
            break
        statement = new[match.start() : match.end()]
        parameter = match.group(1)
        config = indent(get_default(settings, parameter), "    ").strip()
        new = new.replace(statement, config)

    text = readme.read_text().replace(old, new)

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
        new_param = wrap_setup(root, get_config_for(new, parameter))
        text = text.replace(old_param, new_param)

    readme.write_text(text)


def wrap_setup(root: Path, s: str) -> str:
    return f"require('{root.name}').setup({s})\n"


def update_handlers(root: Path) -> None:
    files: list[Path] = [
        root.joinpath("settings.lua"),
        root.joinpath("lib/marks.lua"),
    ]
    lua_types = {lua_type.name(): lua_type for lua_type in get_lua_types(files)}
    names = [
        "render.md.Handler",
        "render.md.handler.Context",
        "render.md.Mark",
        "render.md.mark.Conceal",
        "render.md.mark.Opts",
        "render.md.mark.Line",
        "render.md.mark.Text",
        "render.md.mark.Hl",
    ]
    sections = [lua_types[name].to_str() for name in names]

    handlers = Path("doc/custom-handlers.md")
    old = get_code_block(handlers, names[0], 1)
    new = "\n\n".join(sections) + "\n"
    text = handlers.read_text().replace(old, new)
    handlers.write_text(text)


def get_lua_types(files: list[Path]) -> list[LuaType]:
    result: list[LuaType] = []
    for file in files:
        for comment in get_comments(file):
            # ---@class md.Init: md.Api        -> class
            # ---@field enabled? boolean       -> field
            # ---@alias md.bullet.Text         -> alias
            # ---| string                      -> ---|
            # ---@type md.Config               -> type
            # ---@param opts? md.UserConfig    -> param
            # -- Inlined with 'image' elements -> --
            kind = comment.split()[0].split("@")[-1]
            if kind == "alias":
                result.append(LuaAlias(comment))
            elif kind == "class":
                result.append(LuaClass(comment))
            elif kind in ["field", "---|"]:
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


def get_default(file: Path, name: str | None) -> str:
    if name is None:
        query = """
        (assignment_statement
            (variable_list
                name: (dot_index_expression
                    field: (identifier) @name
                    (#eq? @name "default")))
            (expression_list value: (table_constructor)) @value)
        """
    else:
        query = f"""
        (assignment_statement
            (variable_list
                name: (dot_index_expression
                    table: (dot_index_expression
                        field: (identifier) @name1
                        (#eq? @name1 "{name}"))
                    field: (identifier) @name2
                    (#eq? @name2 "default")))
            (expression_list value: (table_constructor)) @value)
        """
    defaults = ts_query(file, query, "value")
    assert len(defaults) == 1
    return defaults[0]


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
