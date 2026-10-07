# Modern C++ (C++17/20/23)

- Prefer **modern C++ features** over C-style constructs
- Use `auto` when the type is obvious from context
- Use `constexpr` for compile-time constants
- Use structured bindings: `auto [key, value] = map_entry;`

# Coding Style

Follow the [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html) as its baseline, with the adjustments noted below. When in doubt, prefer consistency with the existing codebase over strict adherence to the guide.

## Adjustments to Google style

| Rule | Google default | This project |
|---|---|---|
| Indentation | 2 spaces | 4 spaces |
| Pointer alignment | either side | type side (`void* p`) |
| Enumerator names | `kEnumName` | `PascalCase` |

Everything else follows Google style as written.

## Naming Conventions

### Types
Classes, structs, enums, and type aliases use `PascalCase`.

```cpp
class Widget { ... };
struct FrameOptions { ... };
enum class Status : uint8_t { ... };
using HandlerTable = std::vector<EventHandler>;
```

### Functions and methods
All functions and methods use `snake_case`.

```cpp
void close(Widget& w);
void render(Widget& w, const Context& ctx);
FrameOptions poll_options();
```

### Variables
Local variables and function parameters use `snake_case`.

```cpp
int retry_count = 3;
float elapsed_seconds = 0.016f;
```

### Member variables
Member variables use `snake_case` with a trailing underscore — see Class layout below for an example.

### Constants and enumerators
Compile-time constants (`constexpr`/`const`, fixed for the program's duration) use a leading `k` + `MixedCase` — Google's actual Constant Names rule; `UPPER_SNAKE_CASE` is reserved for macros. Enum values use `PascalCase`.

```cpp
export constexpr int kMaxWidgets = 256;
export constexpr int kDefaultWidth = 800;
export constexpr int kFrameBudgetMs = 16;

enum class Status : uint8_t {
    Idle = 0,
    Active = 1,
    Closed = 2,
};
```

### Modules
Module names use `lower.dot.separated` matching the project namespace hierarchy.

```cpp
export module app.widget;
export module app.input;
export module app.render;
```

### Files
| File type | Convention | Example |
|---|---|---|
| Module interface unit | `snake_case.ixx` | `widget.ixx` |
| Module implementation unit | `snake_case.cpp` | `widget.cpp` |
| Regular header (if needed) | `snake_case.h` | `types.h` |

# Formatting

- Use **clang-format** — no style debates
- Run `clang-format -i <file>` before committing

## Indentation
4 spaces. No tabs.

## Line length
120 characters maximum. Google specifies 80 — 120 is used here to accommodate module-qualified type names without forced wrapping.

## Braces
Opening brace on the same line as the statement that opens the block. No exceptions.

```cpp
// correct
void Widget::close() {
    if (!backend_) {
        return;
    }
}

// wrong
void Widget::close()
{
    if (!backend_)
    {
        return;
    }
}
```

## Spaces
Space after `if`, `for`, `while`, `switch`. No space between function name and `(`.

```cpp
// correct
if (is_valid()) {
    for (int i = 0; i < count; ++i) {
        do_something(i);
    }
}

// wrong
if(is_valid()){
    for(int i=0;i<count;i++){
        do_something(i);
    }
}
```

## Pointer and reference alignment
`*` and `&` bind to the type, not the variable name.

```cpp
// correct
Backend* backend_;
const FrameOptions& options;
void render(Context* ctx);

// wrong
Backend *backend_;
const FrameOptions &options;
void render(Context *ctx);
```

## Blank lines
One blank line between top-level declarations and between function definitions — never two. No blank line immediately after the opening brace or before the closing brace of a function or class body (a namespace body may keep one). clang-format enforces all of this: it inserts the separating line between definitions and collapses any run of blank lines to one.

Function bodies span multiple lines, except short functions defined inside a class body (e.g. `[[nodiscard]] bool is_running() const { return running_; }`) and empty bodies (`{}`).

```cpp
void Widget::close() {
    detach(backend_);
    backend_ = nullptr;
}

void Widget::flush() {
    event_queue_->drain();
}
```
## C++20 specifics

### Module file layout
If the project uses C++20 modules, every module file follows this layout, in this order:

```cpp
module;                              // 1. global module fragment opens here
#include <external_headers.h>        // 2. external includes go here (third-party
                                     //    C headers, STL if not imported as modules)

export module project.feature;       // 3. module declaration

import project.other_feature;        // 4. imports of other project modules only
import project.support;

// 5. exported declarations
export class Widget { ... };
export void do_thing();

// 6. non-exported implementation (or in a separate .cpp)
```

Project modules import other project modules directly (`import project.x;`); nothing gets `import <...>` unless the project has explicitly opted into standard library header units. Module names use `lower.dot.separated` form matching the project's namespace hierarchy (see Naming Conventions → Modules above).

### Concepts
Concepts are named with `PascalCase` and defined in the module that owns the constraint.

```cpp
export template <typename T>
concept Streamable = requires(const T& t, std::ostream& os) {
    { t.write(os) } -> std::same_as<void>;
};
```

### Coroutines
Coroutine return types are named with a `Task` or `Coroutine` suffix. `co_await`, `co_yield`, and `co_return` are always on their own line.

```cpp
Task poll_loop(Widget& widget) {
    while (true) {
        co_await wait_for_event(widget, EVENT_TIMEOUT);
        co_await handle_event(widget);
    }
}
```

## Class layout

Sections appear in this order, each preceded by its access specifier:

```cpp
export class Application {
public:
    // 1. constructors and destructor
    Application();
    ~Application() = default;

    // 2. deleted copy/move (if non-copyable)
    Application(const Application&) = delete;
    Application& operator=(const Application&) = delete;

    // 3. public methods
    void update(const Input& input);
    void render(Context& ctx);

    // 4. [[nodiscard]] queries last among public methods
    [[nodiscard]] bool is_running() const { return running_; }

private:
    // 5. private methods
    void render_background(Context& ctx);
    void render_foreground(Context& ctx);

    // 6. member variables — one per line
    WidgetTree tree_;
    Input input_;
    bool running_ = true;
};
```

## Comments

### When to comment
Comment *why*, not *what*. The code says what it does. Comments explain decisions, constraints, and non-obvious behaviour.

```cpp
// correct — explains a non-obvious decision
// Linear scan: widgets_ stays under 50 entries in practice; a hash
// index would add complexity for no measurable benefit here.
if (contains(widgets_, target)) {
    remove(widgets_, target);
}

// wrong — restates what the code already says
// check if target is in widgets
if (contains(widgets_, target)) {
    remove(widgets_, target);
}
```

### Format
Single-line comments use `//` with one space after. No `/* */` block comments except for file headers. Comments go on their own line above the statement they explain, not trailing at the end of a line of code — a trailing comment can push an otherwise-short line past the column limit and force clang-format to wrap the code instead of the comment.

### Phase markers
Use `// TODO(phaseN):` to flag work deferred to a later phase.

```cpp
// TODO(phase3): replace with coroutine-based state machine
widget.update_placeholder();
```
