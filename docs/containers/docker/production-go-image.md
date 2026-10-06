---
title: Production Go image
description: Multi-stage, non-root и cache-efficient Dockerfile для Go.
tags: [containers, docker, go]
updated: 2026-10-06
---

# Production Go image

Сборочный образ содержит Go и инструменты, а рабочий — только нужный binary и окружение. Так проще воспроизводить artifact и уменьшить доступные инструменты атаки.

Ниже baseline для pure-Go static service. Пути и main package адаптируйте; в CI pin-ьте base images digest (криптографический идентификатор конкретного содержимого) после controlled update.

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

`.dockerignore` исключает `.git`, local binaries, coverage, docs/private config и secrets, но не `go.mod/go.sum`.

## Decisions

- `CGO_ENABLED=0` подходит только без CGO dependencies; иначе используйте compatible runtime libc/libs и build target.
- Distroless содержит минимальный runtime/CA bundle, но нет shell. Для debug используйте separate image/ephemeral container, не добавляйте shell в production.
- `-s -w` уменьшает binary, но может ухудшить symbol/debug workflow; сохраните unstripped artifact отдельно, если нужен.
- Application получает config/secrets runtime, логирует stdout, принимает `SIGTERM`, имеет HTTP/gRPC readiness (готовность к операции или к приёму новой работы в указанном контексте) endpoint и pprof только на protected listener.
- Docker `HEALTHCHECK` необязателен, если orchestrator применяет свои probes; не дублируйте противоречивые policies.

## Build

```bash
docker buildx build --platform linux/amd64,linux/arm64 --push -t registry/app:<immutable-tag> .
```

Проверяйте tests, vulnerability/SBOM, non-root UID, architecture, CA/TLS, timezone semantics, read-only root и graceful stop.

## Условия корректности этого Dockerfile

Пример требует module с `go.mod` и `go.sum`, package `./cmd/service`, Go-совместимых dependencies и Linux target. Если зависимостей нет и go.sum отсутствует, `COPY go.mod go.sum ./` нужно адаптировать. `CGO_ENABLED=0` не подходит для зависимости, которой нужна C-библиотека.

Tests в build stage выполняются на build platform; cross-compilation сама по себе не проверяет работу target binary. Для linux/arm64 нужны отдельный target smoke test и проверка соответствующих resources/credentials. Distroless static подходит статической сборке и не содержит shell: `docker exec sh` там не сработает.

Запустите отдельную проверку read-only filesystem и SIGTERM:

```bash
docker run --name go-smoke --read-only --tmpfs /tmp:rw,size=16m api-image
docker stop --timeout 30 go-smoke
docker inspect --format '{{.State.ExitCode}} {{.State.OOMKilled}}' go-smoke
```

Это команды отдельной smoke fixture; корректный код должен завершиться до KILL, итог зависит от программы. Не запускались в этой Windows-сессии. Если binary пишет cache/config в root filesystem, найдите и явно выделите writable location.

## Источники

- [Dockerfile best practices](https://docs.docker.com/build/building/best-practices/)
- [BuildKit cache optimization](https://docs.docker.com/build/cache/optimize/)

## Проверь себя

1. Почему build для arm64 не заменяет test на arm64?
2. Что сломает static image при CGO_ENABLED=1?

<details>
<summary>Ориентиры для ответа</summary>

1. Компиляция проверяет target code generation, а не реальное выполнение и окружение.
2. Могут отсутствовать нужный dynamic loader/libc/libraries; runtime должен соответствовать binary.

</details>
