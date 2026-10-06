---
title: "Рабочий образ Go-сервиса"
description: "Образ сборки содержит Go и инструменты."
tags: [containers, docker, go]
updated: 2026-10-06
---

# Рабочий образ Go-сервиса

Образ сборки содержит Go и инструменты. Рабочий образ получает только бинарный файл и необходимое окружение. Это уменьшает размер и число лишних программ, но требует явно проверить зависимости запуска.

## Пример Dockerfile

Этот пример рассчитан на статический сервис без cgo. Пути адаптируйте под проект; базовые образы в CI фиксируйте digest после контролируемого обновления.

```dockerfile
# syntax=docker/dockerfile:1

ARG GO_VERSION=1.27.1
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-bookworm AS build

WORKDIR /src
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
    go test ./...

ARG TARGETOS TARGETARCH
RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags="-s -w" -o /out/service ./cmd/service

FROM gcr.io/distroless/static-debian12:nonroot AS runtime
COPY --from=build --chown=nonroot:nonroot /out/service /service

EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/service"]
```

Нужны `go.mod`, `go.sum`, пакет `./cmd/service` и подходящие зависимости. Если без зависимостей нет `go.sum`, строку `COPY` нужно изменить. `.dockerignore` должен исключать секреты, локальные результаты сборки и ненужные данные, сохраняя файлы модуля.

## Условия корректности

`CGO_ENABLED=0` подходит, если зависимости не требуют C. Иначе рабочий образ должен содержать совместимые загрузчик, libc и библиотеки. Distroless static подходит статической программе и не содержит оболочки: `docker exec sh` не сработает.

`-s -w` уменьшает файл ценой отладочной информации. При необходимости сохраните отдельный полный артефакт. Настройки и секреты передавайте при запуске; логи — в stdout. Приложение должно принимать `SIGTERM` и иметь проверку готовности. `pprof` размещайте только на защищённом слушателе. Docker `HEALTHCHECK` не обязателен, если платформа задаёт собственные проверки.

## Сборка и проверка

```bash
docker buildx build --platform linux/amd64,linux/arm64 --push -t registry/app:<immutable-tag> .
```

Проверьте архитектуру, запуск без root, сертификаты TLS, часовые пояса, уязвимости и состав компонентов. Тесты этапа сборки выполняются на его платформе. Сборка для arm64 ещё не доказывает правильный запуск на arm64: нужна проверка результата на целевой платформе.

```bash
docker run --name go-smoke --read-only --tmpfs /tmp:rw,size=16m api-image
docker stop --timeout 30 go-smoke
docker inspect --format '{{.State.ExitCode}} {{.State.OOMKilled}}' go-smoke
```

Команды проверяют файловую систему только для чтения и остановку сигналом; в этой Windows-сессии они не запускались. Если программа пишет в корень, выделите конкретный доступный для записи каталог. При активном запросе остановка должна завершиться до принудительного `SIGKILL`; результат зависит от реализации сервиса.

## Источники

- [Dockerfile best practices](https://docs.docker.com/build/building/best-practices/)
- [BuildKit cache optimization](https://docs.docker.com/build/cache/optimize/)

## Проверь себя

1. Почему сборка arm64 не заменяет запуск и тест на arm64?
2. Что может сломаться у программы с cgo в статическом образе?

<details>
<summary>Ответы</summary>

1. Компиляция не проверяет реальное окружение и выполнение.
2. Могут отсутствовать динамический загрузчик или C-библиотеки.

</details>
