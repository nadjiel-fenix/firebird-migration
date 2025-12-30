import re
import os
import argparse

test = """
LOCAL
  END_LOCAL
  'LOCAL'
  "LOCAL"
    ""LOCAL
  ""\"LOCAL"
  "''LOCAL"
  "''END_LOCAL"
    "'LOCAL'"
  Local
  :LOCAL
"""

test2 = """
LOCAL is active.
The value "LOCAL" is already quoted.
Single quotes 'LOCAL' are also ignored.
But this LOCAL should be changed.
Check END_LOCAL (should be ignored).
"""

test_permissions = """
GRANT  ON tananan
GRANT SELECT ON TABLE
  GRANT ON procedure
"""


def refac_local(text: str) -> str:
    """
    Substitutes any case-insensitive variation of 'LOCAL' with itself in quotations,
    provided it is a whole word and not already inside single or double quotes.
    """
    # Pattern: Match quoted strings OR the word LOCAL (case-insensitive)
    # We capture the word LOCAL in a group to access its original casing later.
    pattern = r'("[^"]*"|\'[^\']*\')|\b(LOCAL)\b'

    def replace_func(match):
        # If group 1 matched, we are inside a quoted string; return it as is.
        if match.group(1):
            return match.group(1)

        # If group 2 matched, it's a standalone variation of LOCAL.
        # We take the exact string found (e.g., 'LoCaL') and wrap it in quotes.
        found_word = match.group(2)
        return f'"{found_word}"'

    return re.sub(pattern, replace_func, text, flags=re.IGNORECASE)


def refac_empty_permissions(text):
    """
    Comments out lines where 'GRANT' and 'ON' appear with only whitespace in between.

    Args:
        text (str): The input SQL or text string.

    Returns:
        str: The modified string with target lines commented out.
    """
    # Regex Pattern Breakdown:
    # (^.* ... .*) : Capturing group for the entire line.
    # ^            : Matches the start of a line (in MULTILINE mode).
    # .* : Matches any characters before the pattern on the same line.
    # GRANT\s+ON   : Matches 'GRANT' followed by 1 or more whitespaces (\s+) and 'ON'.
    # .* : Matches any characters after the pattern on the same line.
    # $            : Matches the end of a line.

    pattern = r"(^.*GRANT\s+ON.*$)"

    # We replace the matched line with '--' followed by the original line content (\1).
    return re.sub(pattern, r"--\1", text, flags=re.MULTILINE)


def process_file(path):
    if not os.path.exists(path):
        print(f"Erro: O arquivo {path} não existe.")
        return

    content = ""

    with open(path, "r", encoding="iso-8859-1") as file:
        content = file.read()

    result = refac_local(content)
    result = refac_empty_permissions(result)

    with open(path, "w", encoding="iso-8859-1") as file:
        file.writelines(result)

    print(f"Refatorado com sucesso!")


def main():
    # 1. Initialize the parser
    parser = argparse.ArgumentParser(
        description="Lê e refatora um script SQL corrigindo erros comuns."
    )

    # 2. Add the path parameter
    parser.add_argument("path", help="O caminho para o script.")

    # 3. Parse the arguments
    args = parser.parse_args()

    # 4. Use the parameter
    process_file(args.path)


if __name__ == "__main__":
    main()
