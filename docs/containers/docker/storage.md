---
title: Docker storage
description: Writable layer, volumes, bind mounts и tmpfs.
tags: [containers, docker, storage]
updated: 2026-09-10
---

# Docker storage

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

## Источники

- [Docker storage overview](https://docs.docker.com/engine/storage/)
- [Volumes](https://docs.docker.com/engine/storage/volumes/)
