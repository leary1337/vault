---
title: Production Go image
description: Multi-stage, non-root и cache-efficient Dockerfile для Go.
tags: [containers, docker, go]
updated: 2026-09-10
---

# Production Go image

Ниже baseline для pure-Go static service. Пути и main package адаптируйте; в CI pin-ьте base images digest после controlled update.

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
- Application получает config/secrets runtime, логирует stdout, принимает `SIGTERM`, имеет HTTP/gRPC readiness endpoint и pprof только на protected listener.
- Docker `HEALTHCHECK` необязателен, если orchestrator применяет свои probes; не дублируйте противоречивые policies.

## Build

```bash
docker buildx build --platform linux/amd64,linux/arm64 --push -t registry/app:<immutable-tag> .
```

Проверяйте tests, vulnerability/SBOM, non-root UID, architecture, CA/TLS, timezone semantics, read-only root и graceful stop.

## Источники

- [Dockerfile best practices](https://docs.docker.com/build/building/best-practices/)
- [BuildKit cache optimization](https://docs.docker.com/build/cache/optimize/)
