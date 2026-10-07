---
name: cpp-coding-standards
description: "Use when writing, reviewing, or refactoring C++ code, or making C++ formatting, naming, or design decisions."
when_to_use: "C++ naming conventions, formatting, file layout, Core Guidelines questions, enforcing consistent style across a C++ codebase."
---

# C++ Coding Standards (C++ Core Guidelines)

Modern C++ (C++17/20/23) standards derived from the [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines), plus this project's own naming and layout conventions. Enforces type safety, resource safety, immutability, and clarity.

## When to Use

- Writing new C++ code (classes, functions, templates, modules)
- Reviewing or refactoring existing C++ code
- Choosing between language features (`enum` vs `enum class`, raw vs smart pointer, exceptions vs error codes)

Not for: non-C++ projects, legacy C codebases that can't adopt modern C++, or bare-metal code where a guideline conflicts with hardware constraints (adapt selectively).

## Project conventions

The Core Guidelines don't prescribe naming or formatting; this project does. Where any example in `references/` differs from these, these win.

| Identifier | Convention | Example |
|---|---|---|
| Classes, structs, enums, aliases, concepts | `PascalCase` | `FrameOptions`, `Streamable` |
| Functions and methods | `snake_case` | `poll_options()` |
| Locals and parameters | `snake_case` | `retry_count` |
| Member variables | `snake_case_` (trailing underscore) | `backend_` |
| Compile-time constants | `k` + `MixedCase` | `kMaxWidgets` |
| Enumerators | `PascalCase` | `Status::Idle` |
| Macros (only) | `UPPER_SNAKE_CASE` | `PROJECT_MODULE_WIDGET_H` |
| Modules | `lower.dot.separated`, matching namespaces | `app.widget` |
| Files | `snake_case` (`.ixx` interface, `.cpp` implementation, `.h` header) | `widget.ixx` |

Formatting (Google base, 4-space indent, 120 columns, `T*`/`T&` bound to the type, one blank line between definitions) is applied by `clang-format`: this plugin's hook formats every C++ file Claude edits at the end of each turn, and the `clang-format` skill handles explicit runs.

**Read `references/coding-style.md` before writing a new file or class** — it holds the module file layout, class section order, comment rules, and C++20 specifics (concepts, coroutines).

## Cross-Cutting Principles

1. **RAII everywhere** (P.8, R.1, E.6, CP.20): bind resource lifetime to object lifetime
2. **Immutability by default** (P.10, Con.1-5, ES.25): start with `const`/`constexpr`; mutability is the exception
3. **Type safety** (P.4, I.4, ES.46-49, Enum.3): use the type system to prevent errors at compile time
4. **Express intent** (P.3, F.1, NL.1-2, T.10): names, types, and concepts communicate purpose
5. **Minimize complexity** (F.2-3, ES.5, Per.4-5): simple code is correct code
6. **Value semantics over pointer semantics** (C.10, R.3-5, F.20, CP.31): prefer returning by value and scoped objects

## Guideline reference

Each file has the area's key rules, DO/DON'T examples, and anti-patterns. Read the one that matches the decision in front of you rather than all of them.

| Read | When you're deciding |
|---|---|
| `references/philosophy-interfaces.md` | API shape, contracts, what a function signature should promise (P.*, I.*) |
| `references/functions.md` | Parameter passing, return values, `constexpr`/pure functions (F.*) |
| `references/classes.md` | Class design, Rule of Zero/Five, hierarchies, virtual destructors (C.*) |
| `references/resources.md` | Ownership, smart pointers, RAII wrappers (R.*) |
| `references/expressions-constants-enums.md` | Initialization, casts, `const`/`constexpr`, `enum class` (ES.*, Con.*, Enum.*) |
| `references/errors.md` | Exceptions vs error codes, exception types, `noexcept` (E.*) |
| `references/concurrency.md` | Threads, locks, shared state, multiple mutexes (CP.*) |
| `references/templates.md` | Templates, concepts, constraining generic code (T.*) |
| `references/stdlib-performance.md` | Standard containers/algorithms, measuring and designing for speed (SL.*, Per.*) |
| `references/source-files.md` | Headers, include guards, `using namespace`, naming rules (SF.*, NL.*) |

## Quick Reference Checklist

Before marking C++ work complete:

- [ ] Names follow the project conventions table above
- [ ] No raw `new`/`delete` — use smart pointers or RAII (R.11)
- [ ] Objects initialized at declaration (ES.20)
- [ ] Variables are `const`/`constexpr` by default (Con.1, ES.25)
- [ ] Member functions are `const` where possible (Con.2)
- [ ] `enum class` instead of plain `enum` (Enum.3)
- [ ] `nullptr` instead of `0`/`NULL` (ES.47)
- [ ] No narrowing conversions (ES.46)
- [ ] No C-style casts (ES.48)
- [ ] Single-argument constructors are `explicit` (C.46)
- [ ] Rule of Zero or Rule of Five applied (C.20, C.21)
- [ ] Base class destructors are public virtual or protected non-virtual (C.35)
- [ ] Templates are constrained with concepts (T.10)
- [ ] No `using namespace` in headers at global scope (SF.7)
- [ ] Headers have include guards and are self-contained (SF.8, SF.11)
- [ ] Locks use RAII (`scoped_lock`/`lock_guard`) (CP.20)
- [ ] Exceptions are custom types, thrown by value, caught by reference (E.14, E.15)
- [ ] `'\n'` instead of `std::endl` (SL.io.50)
- [ ] No magic numbers (ES.45)
