---
title: Fuzzing
description: Coverage-guided fuzz tests для parsers, codecs и trust boundaries.
tags:
  - go
  - testing
  - security
updated: 2026-09-10
---

# Fuzzing

Go toolchain поддерживает coverage-guided fuzzing с Go 1.18. Хорошие targets: parsers, decoders, validation, round-trip и security boundaries.

```go
func FuzzParseID(f *testing.F) {
    f.Add("42")
    f.Add("")
    f.Fuzz(func(t *testing.T, input string) {
        id, err := ParseID(input)
        if err == nil && id < 0 {
            t.Fatalf("negative id %d for %q", id, input)
        }
    })
}
```

```bash
go test -fuzz=FuzzParseID -fuzztime=30s ./pkg
```

Target должен быть быстрым, deterministic и isolated: engine выполняет cases параллельно и в неопределённом порядке. Ограничивайте allocations/recursion/input expansion, иначе fuzzing найдёт только resource exhaustion harness-а. Минимизированный failing input добавляется в corpus и должен воспроизводиться обычным `go test`.

## Источники

- [Go Fuzzing](https://go.dev/doc/security/fuzz/)
- [Fuzzing tutorial](https://go.dev/doc/tutorial/fuzz)
