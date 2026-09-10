---
title: Images и layers
description: OCI image content, writable layer, tags и build cache.
tags: [containers, docker, images]
updated: 2026-09-10
---

# Images и layers

Image состоит из immutable filesystem layers и configuration; digest идентифицирует content manifest, tag — mutable name. Multi-platform tag может указывать на image index с разными manifests для architectures.

Container добавляет writable layer поверх image через storage driver. Удаление/изменение файла создаёт upper-layer metadata/data и не уменьшает lower layer: секрет, добавленный ранним `COPY`, остаётся в history даже после `RUN rm`.

## Build cache

BuildKit строит content-addressed dependency graph. Изменение instruction/input invalidates этот step и dependants. Для быстрого и корректного cache:

- маленький `.dockerignore`, без `.git`, binaries, secrets;
- сначала `COPY go.mod go.sum` + download, затем source;
- `RUN --mount=type=cache` для module/build cache;
- remote cache в ephemeral CI;
- reproducible dependency lock и pinned base policy.

`--no-cache` переисполняет instructions, но не обязательно pull-ит свежий base; для этого нужен `--pull`. Mutable tags ухудшают reproducibility; production provenance фиксирует digest/SBOM/signature и сознательно обновляет его.

Image size влияет на transfer/start/cache и attack surface, но smallest не всегда operable: CA certificates, timezone, libc/CGO и debug needs должны быть явными. Multi-stage build удаляет compiler/source из final image.

## Источники

- [Build cache](https://docs.docker.com/build/cache/)
- [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
