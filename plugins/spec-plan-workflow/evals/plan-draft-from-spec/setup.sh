mkdir -p docs/specs src
cat > docs/specs/undo-history.md <<'SPEC'
# Undo History — SPEC

| Field | Value |
|---|---|
| **Status** | Ready |

## 1. Problem
Users of the text editor can't undo edits; one mistake means retyping.

## 2. Goals
- Ctrl+Z undoes the last edit and Ctrl+Shift+Z redoes it, for at least 100 steps.
- Each undo or redo step applies in under 16 ms.

## 3. Non-Goals
- Undo across sessions.
- Collaborative editing.
- A visible history panel.

## 4. Design
Every edit already goes through `CommandDispatcher` (src/command_dispatcher.py). Record each executed
command with its inverse on a bounded undo stack (100 entries); a new edit clears the redo stack.

### How It Fits Existing Systems
Builds on `CommandDispatcher.execute()`; key bindings live in `src/keymap.py`.

## 5. Open Questions
- [x] Should redo survive a new edit? No — a new edit clears the redo stack.
SPEC
cat > src/command_dispatcher.py <<'PY'
class CommandDispatcher:
    def __init__(self, document):
        self.document = document

    def execute(self, command):
        command.apply(self.document)
PY
cat > src/keymap.py <<'PY'
KEYMAP = {
    "ctrl+s": "save",
    "ctrl+o": "open",
}
PY
