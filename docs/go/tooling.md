---
title: "Пакеты, модули и инструменты Go"
description: Воспроизводимая сборка, зависимости, toolchain, build tags, CGO и проверка уязвимостей.
tags: [go, modules, tooling]
updated: 2026-10-06
---

# Пакеты, модули и инструменты Go

**Package** — исходники одного каталога, которые компилируются вместе. **Module** — набор пакетов с общим `go.mod` и версией. **Toolchain** — конкретные компилятор, стандартная библиотека и команда `go`. Для повторяемой сборки нужны все три: правильный код, выбранные зависимости и известные инструменты.

## go.mod и go.sum

Учебный `go.mod`:

```gomod
module example.org/ads

go 1.27

require golang.org/x/sync v0.19.0
```

Версия dependency здесь пример закреплённого требования, не заявление о последней версии. `go` задаёт минимально требуемый Go и влияет на семантику пакетов. В конкретном проекте выбирайте проверенный patch toolchain отдельно.

`require` задаёт нижние требования к версиям модулей. **MVS** — minimal version selection: для каждого module path выбирается наибольшая требуемая версия из графа, а не «последняя на сервере». Если A требует библиотеку v1.2, а B — v1.4, выбрана v1.4. **go.sum** содержит checksums скачанного содержимого и `go.mod`; это не lockfile списка выбранных версий.

```bash
go mod tidy
go list -m all
go mod graph
go mod why -m golang.org/x/sync
go mod verify
```

`tidy` обновляет требования и checksums под фактические imports/tests — смотрите diff. `list -m all` показывает выбранные версии, `why` объясняет необходимость, `verify` проверяет локальный module cache относительно записанных checksums. Это не проверка качества или отсутствия уязвимостей.

## Toolchain и граница совместимости

С Go 1.21 `GOTOOLCHAIN=auto` может скачать подходящую toolchain, если установленной недостаточно. `toolchain` в главном модуле предлагает версию для работы с ним; это отличается от версии языка у dependency. Для CI закрепите окружение и запишите:

```bash
go version
go env GOTOOLCHAIN GOWORK GOOS GOARCH CGO_ENABLED
go list -m all
go version -m ./service
```

Binary metadata помогает установить, что реально собрано. `go 1.24` в module и compiler 1.27 не позволяют безусловно использовать API 1.25 и обещать поддержку 1.24. Для намеренной совместимости используйте version build constraints и проверку минимальной toolchain; `stdversion` помогает выявить слишком новые symbols.

## replace, workspace и vendor

`replace example.org/lib => ../lib` удобно локально, но CI может не иметь этого каталога. Replace главного модуля меняет граф, а replace в зависимости не управляет графом вашего приложения. Проверка только в `go.work` может скрыть ошибочные требования отдельного module: отдельно запускайте тесты с `GOWORK=off`.

`go mod vendor` создаёт directory зависимостей и `vendor/modules.txt`; выбранные зависимости нужно обновлять согласованно с `go.mod`. Vendor не отменяет проверки версии инструмента, licences и уязвимостей. `go build -mod=readonly` помогает не изменять требования во время CI сборки, но правила vendor mode проверяйте явно: `-mod=vendor` использует vendored sources.

## Приватные зависимости и доверие

`GOPROXY` задаёт источник module download, `GOSUMDB` — службу проверки checksums. **GOPRIVATE** помечает patterns приватных module paths и задаёт defaults для обхода публичного proxy/checksum database через GONOPROXY/GONOSUMDB. Это не настройка credentials: доступ к Git/proxy нужен отдельно.

```bash
go env -w GOPRIVATE=git.example.org/team/*
```

Это постоянное изменение пользовательской Go-конфигурации; выполняйте только когда такая политика нужна. В CI предпочтительнее ограниченные env variables. Не выключайте `GOSUMDB` глобально ради одной приватной dependency. Токены не записывайте в module URL, исходники и build logs.

## Build tags и CGO

```go
//go:build linux && !cgo

package platform

func Backend() string { return "linux without cgo" }
```

Файл выбирается только при выполнении constraint; имя `backend_linux.go` также ограничивает GOOS. Другой target требует альтернативного файла, иначе API может отсутствовать. Build constraints находятся до package с пустой строкой; не превращайте tags в случайное скрытие тестов.

**CGO** связывает Go с C-кодом. Pure-Go cross build часто достаточно `GOOS=linux GOARCH=arm64`, а cgo требует соответствующего C compiler/sysroot/libraries. Binary с динамической libc нельзя автоматически переносить в `scratch` или несовместимый Linux image. Cross compilation не заменяет запуск на целевой platform.

## Проверять разные классы ошибок

```bash
go vet ./...
go test ./...
go test -race ./...
govulncheck ./...
```

`vet` ищет подозрительные конструкции; tests проверяют поведение; race detector — выполненные конфликтующие обращения; `govulncheck` из `golang.org/x/vuln/cmd/govulncheck` сопоставляет зависимости/достижимые вызовы с Go vulnerability database. Ни одна команда не доказывает безопасность всего продукта. Race требует поддерживаемой platform и обычно cgo/C toolchain. Уязвимости проверяйте вместе с версией базы, достижимостью, доступным исправлением и условиями эксплуатации.

Про машинные стадии компиляции, cache и linking см. [компиляцию Go](runtime/compilation.md); про target image — [production Go image](../containers/docker/production-go-image.md).

## Источники

- [Go Modules Reference](https://go.dev/ref/mod)
- [Go Toolchains](https://go.dev/doc/toolchain)
- [Go command: build constraints and environment](https://pkg.go.dev/cmd/go)
- [Go vulnerability management](https://go.dev/doc/security/vuln/)

## Проверь себя

1. Почему тесты в workspace могут пройти, а отдельный module в CI не собраться?
2. Что различает go.sum, vendor и закреплённую toolchain?

<details>
<summary>Ориентиры для ответа</summary>

1. Workspace/replace могут подставлять локальный код и скрывать неверные module requirements. Проверьте module с GOWORK=off и доступные CI inputs.
2. go.sum проверяет скачанное содержимое; vendor хранит выбранные dependency sources; toolchain определяет compiler/standard library. Для повторяемой сборки нужны согласованные и проверенные inputs всех уровней.

</details>
