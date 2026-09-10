---
title: Dockerfile
description: Build context, instructions, multi-stage и runtime command semantics.
tags: [containers, docker, dockerfile]
updated: 2026-09-10
---

# Dockerfile

Dockerfile описывает build stages. Build context — доступные builder files; `COPY ../secret` не должен обходить его. `.dockerignore` уменьшает context и риск утечки.

## Instructions

- `FROM` начинает stage; именуйте `AS build`.
- `WORKDIR` задаёт явный directory.
- `COPY` предпочтительнее `ADD`, если не нужны специальные semantics.
- `RUN` выполняется во время build и создаёт layer/result.
- `ARG` доступен build, `ENV` остаётся в image/runtime; оба не подходят для secrets.
- `USER` задаёт default UID/GID.
- `EXPOSE` документирует port, но не publish-ит его.
- `HEALTHCHECK` запускает command внутри container, если платформа его использует.

`ENTRYPOINT` задаёт executable, `CMD` — default args/command. Exec form передаёт signals process напрямую:

```dockerfile
ENTRYPOINT ["/service"]
CMD ["serve", "--listen=:8080"]
```

Shell form запускает `/bin/sh -c`, меняет signal/PID semantics и expansion. Wrapper script заканчивайте `exec "$@"`.

## Secrets и cache

Не используйте `ARG TOKEN`, `COPY .env` или credential в URL: metadata/layers/cache могут их сохранить. BuildKit secret/SSH mounts доступны только на `RUN` и не попадают в result, если command сам их не записал.

Объединяйте package install + cleanup в один `RUN` для layer correctness, но не склеивайте всё ценой нечитаемого cache graph. Tests/scans выполняются отдельным target/CI gate.

## Источники

- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Build secrets](https://docs.docker.com/build/building/secrets/)
