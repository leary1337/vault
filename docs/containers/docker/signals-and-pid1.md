---
title: Signals и PID 1
description: Entrypoint, signal delivery, zombie reaping и graceful stop.
tags: [containers, docker, signals]
updated: 2026-09-10
---

# Signals и PID 1

Container main process обычно PID 1 в PID namespace. `docker stop` посылает configured stop signal (обычно `SIGTERM`), ждёт timeout и затем `SIGKILL`.

Shell-form command создаёт shell PID 1, который может не forward-ить signal child:

```dockerfile
# плохо для прямой доставки SIGTERM
ENTRYPOINT /service

# process service становится PID 1
ENTRYPOINT ["/service"]
```

Wrapper должен завершаться `exec /service "$@"`. Если application создаёт children, PID 1 обязан reap-ить zombies; используйте встроенный reaper или `docker run --init`, если runtime не справляется. Один main process plus helpers допустим, но supervisor semantics должны быть осознанными.

## Graceful stop

Application по `SIGTERM` прекращает intake/readiness, закрывает listeners, drain-ит HTTP/gRPC/queue work в deadline и выходит. Grace period Docker/orchestrator должен быть длиннее internal shutdown budget. `SIGKILL` не запускает cleanup.

`STOPSIGNAL` меняет signal image, но нестандартный выбор должен поддерживаться app/platform. Healthcheck не заменяет signal handling и не всегда влияет на restart вне Swarm/Compose policy.

## Проверка

```bash
docker inspect --format '{{.State.Pid}} {{.Config.Entrypoint}} {{.Config.Cmd}}' <container>
docker stop --time 30 <container>
docker top <container>
```

Integration test должен держать active request, послать TERM, проверить прекращение новых и bounded completion старого.

## Источники

- [Dockerfile ENTRYPOINT](https://docs.docker.com/reference/dockerfile/#entrypoint)
- [docker container stop](https://docs.docker.com/reference/cli/docker/container/stop/)
