from dataclasses import dataclass
from pathlib import Path

from tree_sitter_languages import get_language, get_parser


@dataclass(frozen=True)
class LuaClass:
    name: str
    fields: list[str]

    def validate(self) -> None:
        for field in self.fields:
            if "User" in self.name:
                self.validate_user_field(field)
            else:
                self.validate_non_user_field(field)

    def validate_user_field(self, field: str) -> None:
        # User classes are expected to have optional fields
        assert "?" in field, f"Field must be optional: {field}"

    def validate_non_user_field(self, field: str) -> None:
        # Non user classes are expected to have mandatory fields with some exceptions
        optional: bool = False
        optional_fields: list[str] = ["extends"] if "Handler" in self.name else []
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
    init_file = Path("lua/render-markdown/init.lua")
    update_types(init_file, Path("lua/render-markdown/types.lua"))
    update_readme(init_file, Path("README.md"))
    update_custom_handlers(init_file, Path("doc/custom-handlers.md"))


def update_types(init_file: Path, types_file: Path) -> None:
    lines: list[str] = ["---@meta", ""]
    for lua_class in get_classes(init_file):
        lua_class.validate()
        lines.extend(lua_class.to_public_lines())
    types_file.write_text("\n".join(lines))


def update_readme(init_file: Path, readme_file: Path) -> None:
    old_config = get_code_block(readme_file, "log_level", 1)
    new_config = wrap_setup(get_default_config(init_file))
    text = readme_file.read_text().replace(old_config, new_config)

    parameters: list[str] = ["heading", "code", "dash", "bullet", "checkbox"]
    parameters.extend(["quote", "pipe_table", "callout", "link", "sign"])
    for parameter in parameters:
        old_param = get_code_block(readme_file, f"\n    {parameter} = {{", 2)
        new_param = wrap_setup(get_config_for(new_config, f"{parameter} = {{"))
        text = text.replace(old_param, new_param)

    readme_file.write_text(text)


def update_custom_handlers(init_file: Path, handler_file: Path) -> None:
    class_name: str = "render.md.Handler"
    old = get_code_block(handler_file, class_name, 1)
    new = "\n".join(
        [
            get_class(init_file, "render.md.Mark").to_str(),
            "",
            get_class(init_file, class_name).to_str(),
        ]
    )
    text = handler_file.read_text().replace(old, new)
    handler_file.write_text(text)


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


def wrap_setup(value: str) -> str:
    return f"require('render-markdown').setup({value})"


def get_config_for(config: str, parameter: str) -> str:
    lines: list[str] = config.splitlines()
    param_start: int | None = None
    for i, line in enumerate(lines):
        if parameter in line:
            param_start = i
            break
    assert param_start is not None

    start_line: int = param_start
    for i in range(param_start - 1, 0, -1):
        if "--" not in lines[i]:
            start_line = i + 1
            break

    end_line: int = param_start
    level: int = 0
    for i in range(param_start, len(lines)):
        level += lines[i].count("{") - lines[i].count("}")
        if level == 0:
            end_line = i
            break

    return "\n".join(["{"] + lines[start_line : end_line + 1] + ["}"])


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


def get_code_block(file: Path, content: str, n: int) -> str:
    query = "(code_fence_content) @content"
    code_blocks = ts_query(file, query, "content")
    code_blocks = [code for code in code_blocks if content in code]
    assert len(code_blocks) == n, f"Expected {n}, Found {len(code_blocks)}"
    return code_blocks[n - 1]


def ts_query(file: Path, query: str, target: str) -> list[str]:
    ts_language: str = {
        ".lua": "lua",
        ".md": "markdown",
    }[file.suffix]
    parser = get_parser(ts_language)
    tree = parser.parse(file.read_text().encode())

    ts_query = get_language(ts_language).query(query)
    captures = ts_query.captures(tree.root_node)

    values: list[str] = []
    for node, capture in captures:
        if capture == target:
            values.append(node.text.decode())
    return values


if __name__ == "__main__":
    main()
