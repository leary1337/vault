---
title: Docker
description: Images, containers, resources, security и production Go builds.
tags: [containers, docker]
updated: 2026-10-06
---

# Docker

Образ — шаблон файлов и настроек, container — запущенный из него процесс с собственным окружением. На Linux containers делят ядро host; в Docker Desktop обычно используется Linux VM. Приложение должно уметь принимать config, ограничивать resources и корректно останавливаться.

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
