---
title: Docker
description: Images, containers, resources, security и production Go builds.
tags: [containers, docker]
updated: 2026-09-10
---

# Docker

Image — immutable content-addressed filesystem/config template; container — isolated process с writable layer и runtime configuration. Docker использует Linux namespaces/cgroups, а не создаёт отдельный kernel/VM.

Container должен быть replaceable: config снаружи, durable data в volume/service, logs в stdout/stderr, shutdown bounded. Image build воспроизводим, сканируем и отделён от runtime secrets.

Исходная пустая Obsidian-страница удалена после полного rewrite; она остаётся доступна в Git history.


## Темы

- [Docker networking](networking.md)
- [Docker resources](resources.md)
- [Docker security](security.md)
- [Docker storage](storage.md)
- [Dockerfile](dockerfile.md)
- [Images и layers](images-and-layers.md)
- [Production Go image](production-go-image.md)
- [Signals и PID 1](signals-and-pid1.md)

## Источники

- [Docker Engine documentation](https://docs.docker.com/engine/)
- [Docker build documentation](https://docs.docker.com/build/)
