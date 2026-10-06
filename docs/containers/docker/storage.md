---
title: Docker storage
description: Writable layer, volumes, bind mounts и tmpfs.
tags: [containers, docker, storage]
updated: 2026-10-06
---

# Docker storage

Writable layer относится к одному container. Volume переживает его замену, bind mount показывает путь host, tmpfs хранит временные данные в памяти.

Container writable layer исчезает при удалении container и зависит от storage driver. Не храните там единственную копию durable data.

## Mount types

- Volume управляется Docker, имеет независимый lifecycle и подходит для persistent application data.
- Bind mount отображает точный host path; удобен для development/config, но связывает deployment с host layout и даёт доступ к host filesystem.
- tmpfs хранит данные в host memory/swap, исчезает при stop и подходит transient sensitive/high-I/O state с memory limits.

Mount скрывает image content в target path на время container. UID/GID permissions — numeric Linux identities, а не совпадение username strings.

```bash
docker volume create pg-data
docker run --mount type=volume,src=pg-data,dst=/var/lib/app app
docker run --mount type=bind,src=/srv/config,dst=/etc/app,readonly app
```

Volumes не являются backup: corruption/delete сохраняются. Backup должен быть application-consistent (DB snapshot/log protocol), проверяться restore test и храниться вне failure domain host.

Writable-layer heavy writes увеличивают copy-up/CoW overhead и complicate cleanup. Logs направляйте stdout/stderr с bounded logging driver/rotation; unbounded json logs могут заполнить host disk.

Root filesystem `--read-only` плюс explicit writable tmpfs/volume уменьшает mutation surface и выявляет скрытые runtime writes.

## Предел долговечности volume

```bash
docker volume create app-data
docker run --mount type=volume,src=app-data,dst=/data app-image
```

Замена container с тем же volume сохраняет данные. Но отказ диска/host, ошибочное удаление или испорченная запись остаются отказами. Для БД backup должен учитывать transaction/log protocol; копия directory во время записи может быть непригодна для restore.

Bind mount с `readonly` защищает от записи через этот mount, но не от чтения лишнего секрета. Выдавайте минимальный host path, не `/`. tmpfs учитывается в memory, а при swap может оказаться на диске: это не универсальная гарантия «секрет никогда не записан физически». Проверьте memory/swap policy и backup retention.

## Источники

- [Docker storage overview](https://docs.docker.com/engine/storage/)
- [Volumes](https://docs.docker.com/engine/storage/volumes/)

## Проверь себя

1. Чем volume отличается от backup?
2. Почему tmpfs влияет на memory limit?

<details>
<summary>Ориентиры для ответа</summary>

1. Volume сохраняет текущее состояние, включая повреждение; backup отдельная восстановимая копия.
2. Его данные занимают память и учитываются соответствующими resource controllers.

</details>
