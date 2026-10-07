mkdir -p docs/specs
cat > docs/specs/undo-history.md <<'SPEC'
# Undo History — SPEC

| Field | Value |
|---|---|
| **Status** | Ready |

## 1. Problem
Users can't undo edits.

## 2. Goals
- Make undo feel good.

## 3. Non-Goals

## 4. Design
Keep a stack of commands; unlimited depth.

## 5. Open Questions
- [ ] Should redo survive a new edit?
SPEC
