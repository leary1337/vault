---
title: Компиляция и сборка Go
description: Frontend, SSA, code generation, linking и воспроизводимая диагностика compiler decisions.
tags:
  - go
  - compiler
  - runtime
updated: 2026-10-01
created: 2024-07-27
---

# Компиляция и сборка Go

Standard toolchain parses source, type-checks packages, преобразует код во внутреннее representation/SSA, оптимизирует, генерирует machine code и linking executable/library. Конкретный pipeline и эвристики меняются между releases.

## Packages и build cache

`go build` строит package dependency graph и переиспользует build cache. `go.mod` задаёт module requirements; выбранные версии определяются module graph и minimal version selection с учётом `replace`/`exclude` и workspace. `go.sum` хранит checksums содержимого модулей и их `go.mod`, а не является lockfile выбранных зависимостей. Build constraints и `GOOS`/`GOARCH` выбирают files.

С Go 1.21 `go` directive задаёт минимально требуемую версию Go; `toolchain` предлагает toolchain для работы с главным модулем. При `GOTOOLCHAIN=auto` команда может переключиться на более новую toolchain. Это отличается от language version конкретного пакета: например, семантика loop variables определяется его `go` directive/build constraints.

```bash
go build ./cmd/service
GOOS=linux GOARCH=amd64 go build ./cmd/service
go list -deps ./cmd/service
```

Cross-compilation с pure Go обычно проста; cgo требует подходящий cross C toolchain и platform libraries.

## Inlining и escape analysis

Compiler может inline calls, eliminate bounds checks/dead code и выбрать stack/heap placement. Наблюдаемое поведение однопоточной корректной программы и правила memory model должны сохраняться. Compiler optimization не «создаёт race» в race-free code; исходная программа с data race уже не имеет нужного happens-before.

```bash
go build -gcflags="all=-m=2" ./...
go build -gcflags="all=-S" ./path/to/pkg
```

Не зашивайте compiler diagnostics в архитектуру: decisions зависят от version, target и call context.

## Linking и binary metadata

Go linker собирает compiled packages и runtime, удаляет часть недостижимого code/data и записывает build information. Проверить provenance:

```bash
go version -m ./service
go tool buildid ./service
```

`-ldflags=-s -w` уменьшает binary ценой debug/symbol information; применяйте только если операционный выигрыш важнее diagnostics. Для reproducible supply chain фиксируйте toolchain/module inputs и публикуйте SBOM/provenance отдельно.

## PGO

CPU profile может влиять на optimization decisions через `-pgo`/`default.pgo`; см. [Profile-guided optimization](../performance/pgo.md). Это не меняет language semantics и требует проверки representative workload.

## Источники

- [Go Modules Reference: MVS и go.sum](https://go.dev/ref/mod)
- [Go Toolchains](https://go.dev/doc/toolchain)
- [Go command documentation](https://pkg.go.dev/cmd/go)
- [Go compiler command](https://pkg.go.dev/cmd/compile)
- [Go linker command](https://pkg.go.dev/cmd/link)
- [Go PGO](https://go.dev/doc/pgo)
