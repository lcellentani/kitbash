#!/usr/bin/env bash
# Formats the C++ files Claude edited, once per turn.
#   record — PostToolUse(Edit|Write): append the edited path to this session's pending list.
#   flush  — Stop: run clang-format -i on the pending files, then clear the list.
# Files are formatted only against a .clang-format found above them (--fallback-style=none),
# so projects without one are left untouched. Always exits 0: formatting must never block a turn.

input=$(cat)

# Extract a top-level string field from the hook's JSON input without depending on jq.
field() {
    printf '%s' "$input" |
        grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" |
        head -n 1 |
        sed -E 's/^"[^"]*"[[:space:]]*:[[:space:]]*"(.*)"$/\1/; s/\\\\/\\/g'
}

session=$(field session_id)
[ -n "$session" ] || exit 0
pending="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}}/clang-format-pending-${session}.txt"

case "${1:-}" in
record)
    path=$(field file_path)
    path=${path//\\//}
    case "$path" in
    *.cpp | *.cc | *.cxx | *.h | *.hh | *.hpp | *.ixx) ;;
    *) exit 0 ;;
    esac
    case "$path" in
    */third_party/* | */external/* | */vendor/* | */build/*) exit 0 ;;
    esac
    mkdir -p "$(dirname "$pending")" && printf '%s\n' "$path" >>"$pending"
    ;;
flush)
    [ -f "$pending" ] || exit 0
    files=()
    while IFS= read -r f; do
        [ -f "$f" ] && files+=("$f")
    done < <(sort -u "$pending")
    rm -f "$pending"
    if [ ${#files[@]} -gt 0 ] && command -v clang-format >/dev/null 2>&1; then
        clang-format -i --style=file --fallback-style=none "${files[@]}" 2>/dev/null
    fi
    ;;
esac
exit 0
