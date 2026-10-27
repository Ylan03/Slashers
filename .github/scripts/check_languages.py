#!/usr/bin/env python3
"""Advisory check of the translation files (gamemode/languages/*.lua).

- Keys used in the Lua code but missing from en.lua (shown as "Unknow key string" in game).
- Keys of en.lua missing from the other languages (the game falls back on the default language).

Prints GitHub annotations. Always exits 0: translations never block a PR.
"""
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[2]
LANG_DIR = ROOT / "gamemode" / "languages"
KEY_DEF = re.compile(r'LANG\["([^"]+)"\]\s*=')
# GetString("key") and net.WriteTable({"key", ...}) sent to notification / objective panels
KEY_USE = [
    re.compile(r'GetString\(\s*"([a-z0-9_]+)"'),
    re.compile(r'WriteTable\(\s*\{\s*"([a-z0-9_]+)"'),
]


def keys_of(path):
    return set(KEY_DEF.findall(path.read_text(encoding="utf-8", errors="replace")))


def main():
    reference = keys_of(LANG_DIR / "en.lua")

    used = {}
    for lua in list((ROOT / "gamemode").rglob("*.lua")) + list((ROOT / "entities").rglob("*.lua")):
        if lua.parent == LANG_DIR:
            continue
        text = lua.read_text(encoding="utf-8", errors="replace")
        for pattern in KEY_USE:
            for match in pattern.finditer(text):
                line = text.count("\n", 0, match.start()) + 1
                used.setdefault(match.group(1), (lua.relative_to(ROOT), line))

    missing_ref = sorted(k for k in used if k not in reference)
    for key in missing_ref:
        path, line = used[key]
        print(f"::warning file={path},line={line},title=Missing translation key::'{key}' is used but not defined in en.lua")

    for lang in sorted(LANG_DIR.glob("*.lua")):
        if lang.name == "en.lua":
            continue
        missing = sorted(reference - keys_of(lang))
        if missing:
            rel = lang.relative_to(ROOT)
            print(f"::notice file={rel},title={lang.stem}: {len(missing)} missing key(s)::{', '.join(missing)}")

    print(f"Checked {len(used)} used keys against {len(reference)} keys in en.lua.")


if __name__ == "__main__":
    main()
