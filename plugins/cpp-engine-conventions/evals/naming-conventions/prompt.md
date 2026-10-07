---
description: Claude writes a C++ header that follows the project naming conventions where they differ from Google style (snake_case methods, PascalCase enumerators).
tags: [cpp, standards]
max_turns: 15
timeout_seconds: 480
allowed_tools: [Read, Glob, Grep, Skill, Write]
---

In this C++20 project, create `rate_limiter.h` containing a thread-safe token-bucket rate limiter class. It needs a compile-time constant for the maximum number of tokens, an enum class for the outcome of an acquire attempt (acquired, or rate limited), and methods to try to take a token, to refill the bucket, and to report how many tokens remain. Follow the project's C++ coding standards. Just write the header; don't compile or test it.
