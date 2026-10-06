---
title: Dockerfile
description: Build context, instructions, multi-stage и runtime command semantics.
tags: [containers, docker, dockerfile]
updated: 2026-10-06
---

# Dockerfile

Dockerfile — рецепт сборки образа. Build запускает инструкции и сохраняет результат; container потом запускает уже готовый executable с заданными аргументами.

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

## Build и run легко перепутать

```dockerfile
FROM alpine:3.22
RUN printf 'built\n' > /message.txt
ENTRYPOINT ["cat"]
CMD ["/message.txt"]
```

Учебный образ: `docker build -t message .`, затем `docker run --rm message` печатает `built`. `docker run --rm message /etc/os-release` заменяет CMD, но сохраняет ENTRYPOINT и вызовет `cat /etc/os-release`. `RUN` при старте container повторно не выполняется. Версия base здесь пример, а не рекомендация последнего patch; для воспроизводимости фиксируют digest (криптографический идентификатор конкретного содержимого).

Dockerfile context задаётся последним аргументом build, а путь файла — `-f`; это независимые вещи. Если context слишком широк, `.dockerignore` должен исключать credentials и ненужные данные до передачи builder.

## Источники

- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Build secrets](https://docs.docker.com/build/building/secrets/)

## Проверь себя

1. Что заменяет аргумент после image у docker run?
2. Удалит ли RUN rm секрет из раннего COPY?

<details>
<summary>Ориентиры для ответа</summary>

1. Обычно CMD/default args, ENTRYPOINT сохраняется.
2. Нет, он остаётся в нижнем layer; secrets не должны попадать туда вообще.

</details>
