---
description: The Stop hook formats a C++ file Claude wrote, without Claude running any formatter.
tags: [cpp, hook]
max_turns: 6
allowed_tools: [Write]
---

Create these two files exactly as given, byte for byte. Don't run, apply, or simulate any formatting yourself.

1. `.clang-format` containing:

```
BasedOnStyle: Google
IndentWidth: 4
```

2. `math.cpp` containing this single line:

```
int mul(int a,int b){return a*b;}
```
