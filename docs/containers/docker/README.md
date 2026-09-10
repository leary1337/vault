---
title: Docker
description: Images, containers, resources, security и production Go builds.
tags: [containers, docker]
updated: 2026-09-10
---

# Docker

Image — immutable content-addressed filesystem/config template; container — isolated process с writable layer и runtime configuration. Docker использует Linux namespaces/cgroups, а не создаёт отдельный kernel/VM.

Читайте: [images/layers](images-and-layers.md) → [Dockerfile](dockerfile.md) → networking/storage/resources → PID 1/signals → security → [production Go image](production-go-image.md).

Container должен быть replaceable: config снаружи, durable data в volume/service, logs в stdout/stderr, shutdown bounded. Image build воспроизводим, сканируем и отделён от runtime secrets.

Исходная пустая Obsidian-страница удалена после полного rewrite; она остаётся доступна в Git history.

## Источники

- [Docker Engine documentation](https://docs.docker.com/engine/)
- [Docker build documentation](https://docs.docker.com/build/)
