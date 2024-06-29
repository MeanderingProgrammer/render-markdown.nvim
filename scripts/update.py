from dataclasses import dataclass
from pathlib import Path

from tree_sitter_languages import get_language, get_parser


@dataclass(frozen=True)
class LuaClass:
    name: str
    fields: list[str]

    def validate(self) -> None:
        optional_fields: list[str] = ["extends"] if "Handler" in self.name else []
        if "User" in self.name:
            # User classes are expected to have optional fields
            for field in self.fields:
                assert "?" in field, f"Field must be optional: {field}"
        else:
            # Non user classes are expected to have mandatory fields with some exceptions
            for field in self.fields:
                optional: bool = False
                for optional_field in optional_fields:
                    if optional_field in field:
                        optional = True
                if not optional:
                    assert "?" not in field, f"Field must be mandatory: {field}"

    def to_public_lines(self) -> list[str]:
        if "User" not in self.name:
            return []
        lines: list[str] = [self.name.replace("User", "")]
        for field in self.fields:
            lines.append(field.replace("User", "").replace("?", ""))
        lines.append("")
        return lines

    def to_str(self) -> str:
        lines: list[str] = [self.name]
        lines.extend(self.fields)
        return "\n".join(lines)

    @staticmethod
    def from_lines(lines: list[str]) -> "LuaClass":
        return LuaClass(name=lines[0], fields=lines[1:])


def main() -> None:
    init_file: Path = Path("lua/render-markdown/init.lua")
    update_types(init_file)
    update_readme(init_file)
    update_custom_handlers(init_file)


def update_types(init_file: Path) -> None:
    lines: list[str] = []
    for lua_class in get_classes(init_file):
        lua_class.validate()
        lines.extend(lua_class.to_public_lines())

    types_file: Path = Path("lua/render-markdown/types.lua")
    types_file.write_text("\n".join(lines))


def update_readme(init_file: Path) -> None:
    file = Path("README.md")

    old = get_code_block(file, "enabled")
    default_config = get_default_config(init_file)
    new = "require('render-markdown').setup(" + default_config + ")"

    file.write_text(file.read_text().replace(old, new))


def update_custom_handlers(init_file: Path) -> None:
    file = Path("doc/custom-handlers.md")

    class_name: str = "render.md.Handler"
    old = get_code_block(file, class_name)
    new = get_class(init_file, class_name).to_str()

    file.write_text(file.read_text().replace(old, new))


def get_class(init_file: Path, name: str) -> LuaClass:
    lua_classes = get_classes(init_file)
    results = [lua_class for lua_class in lua_classes if name in lua_class.name]
    assert len(results) == 1
    return results[0]


def get_classes(init_file: Path) -> list[LuaClass]:
    # Group comments into class + fields
    lua_classes: list[LuaClass] = []
    current: list[str] = []
    for comment in get_comments(init_file):
        comment_type: str = comment.split()[0].split("@")[-1]
        if comment_type == "class":
            if len(current) > 0:
                lua_classes.append(LuaClass.from_lines(current))
            current = [comment]
        elif comment_type == "field":
            current.append(comment)
    lua_classes.append(LuaClass.from_lines(current))
    return lua_classes


def get_comments(file: Path) -> list[str]:
    query = "(comment) @comment"
    return ts_query(file, query, "comment")


def get_default_config(file: Path) -> str:
    query = """
        (variable_assignment(
            (variable_list(
                variable field: (identifier) @name
                (#eq? @name "default_config")
            ))
            (expression_list value: (table)) @value
        ))
    """
    default_configs = ts_query(file, query, "value")
    assert len(default_configs) == 1
    return default_configs[0]


def get_code_block(file: Path, content: str) -> str:
    query = "(code_fence_content) @content"
    code_blocks = ts_query(file, query, "content")
    code_blocks = [code for code in code_blocks if content in code]
    assert len(code_blocks) == 1
    return code_blocks[0]


def ts_query(file: Path, query_string: str, target: str) -> list[str]:
    ts_language: str = {
        ".lua": "lua",
        ".md": "markdown",
    }[file.suffix]
    parser = get_parser(ts_language)
    tree = parser.parse(file.read_text().encode())

    language = get_language(ts_language)
    query = language.query(query_string)
    captures = query.captures(tree.root_node)

    values: list[str] = []
    for node, capture in captures:
        if capture == target:
            values.append(node.text.decode())
    return values


if __name__ == "__main__":
    main()
