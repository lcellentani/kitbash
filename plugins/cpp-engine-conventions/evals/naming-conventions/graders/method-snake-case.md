---
type: regex
target: { source: file, path: rate_limiter.h }
pattern: '\b(bool|void|int|auto|size_t|std::size_t|[A-Z]\w*)\s+[A-Z][a-z0-9]+[A-Z]\w*\s*\('
match: not_contains
---
