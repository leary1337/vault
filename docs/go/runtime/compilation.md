---
title: Компиляция и сборка Go
description: Frontend, SSA, code generation, linking и воспроизводимая диагностика compiler decisions.
tags:
  - go
  - compiler
  - runtime
updated: 2026-10-06
created: 2024-07-27
---

# Компиляция и сборка Go

Компилятор проверяет типы и превращает Go-код в машинные инструкции. Команда go также выбирает файлы, зависимости и связывает программу с runtime.

Standard toolchain parses source, type-checks packages, преобразует код во внутреннее representation/SSA, оптимизирует, генерирует machine code и linking executable/library. Конкретный pipeline и эвристики меняются между releases.

Про выбор dependencies, workspace, vendor и приватные modules см. [пакеты и инструменты](../tooling.md).

## Packages и build cache

`go build` строит package dependency graph и переиспользует build cache. `go.mod` задаёт module requirements; выбранные версии определяются module graph и minimal version selection с учётом `replace`/`exclude` и workspace. `go.sum` хранит checksums содержимого модулей и их `go.mod`, а не является lockfile выбранных зависимостей. Build constraints и `GOOS`/`GOARCH` выбирают files.

С Go 1.21 `go` directive задаёт минимально требуемую версию Go; `toolchain` предлагает toolchain для работы с главным модулем. При `GOTOOLCHAIN=auto` команда может переключиться на более новую toolchain. Это отличается от language version конкретного пакета: например, семантика loop variables определяется его `go` directive/build constraints.

```bash
go build ./cmd/service
GOOS=linux GOARCH=amd64 go build ./cmd/service
go list -deps ./cmd/service
```

Cross-compilation с pure Go обычно проста; cgo требует подходящий cross C toolchain и platform libraries.

## Inlining и escape (выход срока жизни объекта за пределы локального stack (стек вызовов goroutine) frame) analysis

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

## Modules, packages и internal

Module — набор пакетов с общим `go.mod` и путём версии. Package — каталог исходников, которые компилируются вместе; тестовые `*_test.go` выбираются отдельно. Внешний код импортирует package, а `go get` изменяет требования module. Package под `internal` можно импортировать только из разрешённого родительского дерева; это граница зависимости, а не защита секрета.

```bash
go mod tidy
go mod graph
go list -m all
go mod verify
go vet ./...
go test ./...
```

`tidy` меняет `go.mod`/`go.sum`, поэтому просмотрите diff. `verify` проверяет скачанный cache относительно checksum, но не говорит, безопасна ли библиотека. `vet` находит подозрительные конструкции, например копирование lock, но не заменяет tests. Проверка уязвимых достижимых символов — отдельный `govulncheck ./...` из `golang.org/x/vuln/cmd/govulncheck`.

Для Go 1.27 `go test` включает `stdversion`: используемый API должен соответствовать `go` directive. Новая установленная toolchain не даёт права объявлять совместимость с Go 1.20 и использовать API 1.25 без build constraints.

## Источники

- [Go Modules Reference: MVS и go.sum](https://go.dev/ref/mod)
- [Go Toolchains](https://go.dev/doc/toolchain)
- [Go command documentation](https://pkg.go.dev/cmd/go)
- [Go compiler command](https://pkg.go.dev/cmd/compile)
- [Go linker command](https://pkg.go.dev/cmd/link)
- [Go PGO](https://go.dev/doc/pgo)

## Проверь себя

1. Почему go.sum не lockfile?
2. Что означает проход go vet?

<details>
<summary>Ориентиры для ответа</summary>

1. Он содержит checksums; выбранные версии задаются graph требований и MVS.
2. Проверенные анализаторами подозрительные конструкции не найдены; корректность программы не доказана.

</details>
