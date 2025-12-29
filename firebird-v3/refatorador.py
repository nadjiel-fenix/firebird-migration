from pathlib import Path


def is_identifier_char(ch):
    return ch.isalnum() or ch == "_"


def replace_unquoted_local_sql(text, replacement):
    result = []
    in_single = False
    in_double = False
    i = 0

    while i < len(text):
        ch = text[i]

        # SQL escaped single quote: ''
        if in_single and ch == "'" and i + 1 < len(text) and text[i + 1] == "'":
            result.append("''")
            i += 2
            continue

        # Toggle single-quoted strings
        if ch == "'" and not in_double:
            in_single = not in_single
            result.append(ch)
            i += 1
            continue

        # Toggle double-quoted identifiers
        if ch == '"' and not in_single:
            in_double = not in_double
            result.append(ch)
            i += 1
            continue

        # Replace LOCAL only when NOT inside quotes
        if not in_single and not in_double and text.startswith("LOCAL", i):
            before = text[i - 1] if i > 0 else ""
            after = text[i + 5] if i + 5 < len(text) else ""

            if not is_identifier_char(before) and not is_identifier_char(after):
                result.append(replacement)
                i += 5
                continue

        result.append(ch)
        i += 1

    return "".join(result)


if __name__ == "__main__":
    path = Path(
        "C:/APS/Util/migracao-firebird/firebird-v3.0/bancos/merc-pedrinho/metadados-problematicos.sql"
    )

    content = path.read_text(encoding="latin-1")

    new_content = replace_unquoted_local_sql(content, '"LOCAL"')

    path.write_text(new_content, encoding="latin-1")
