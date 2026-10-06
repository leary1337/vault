---
title: "Docker"
description: "Образ содержит шаблон файлов и настройки."
tags: [containers, docker]
updated: 2026-10-06
---

# Docker

Образ содержит шаблон файлов и настройки. Контейнер — запущенные из него процессы с отдельным окружением. На Linux контейнеры делят ядро машины; Docker Desktop обычно запускает их в Linux-виртуальной машине.

Статьи объясняют, как создать образ, передать настройки, открыть сеть, сохранить данные и корректно остановить приложение. Отдельно разобраны пределы ресурсов и полномочий.

## Темы

- [Сеть Docker](networking.md)
- [Ресурсы Docker](resources.md)
- [Безопасность Docker](security.md)
- [Хранение данных Docker](storage.md)
- [Dockerfile](dockerfile.md)
- [Образы и слои](images-and-layers.md)
- [Рабочий образ Go-сервиса](production-go-image.md)
- [Сигналы и PID 1](signals-and-pid1.md)

## Источники

- [Docker Engine documentation](https://docs.docker.com/engine/)
- [Docker build documentation](https://docs.docker.com/build/)
