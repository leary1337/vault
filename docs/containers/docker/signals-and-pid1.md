---
title: Signals и PID 1
description: Entrypoint, signal delivery, zombie reaping и graceful stop.
tags: [containers, docker, signals]
updated: 2026-10-06
---

# Signals и PID 1

Первый процесс namespace должен получать сигналы и забирать status завершённых детей. Shell-wrapper может перехватить сигнал до приложения.

Container main process обычно PID 1 в PID namespace. `docker stop` посылает configured stop signal (обычно `SIGTERM`), ждёт timeout и затем `SIGKILL`.

Shell-form command создаёт shell PID 1, который может не forward-ить signal child:

```dockerfile
# плохо для прямой доставки SIGTERM
ENTRYPOINT /service

# process service становится PID 1
ENTRYPOINT ["/service"]
```

Wrapper должен завершаться `exec /service "$@"`. Если application создаёт children, PID 1 обязан reap (забрать status завершённого дочернего process)-ить zombies; используйте встроенный reaper или `docker run --init`, если runtime не справляется. Один main process plus helpers допустим, но supervisor semantics должны быть осознанными.

## Graceful stop

Application по `SIGTERM` прекращает intake/readiness, закрывает listeners, drain (завершение уже принятой работы)-ит HTTP/gRPC/queue work в deadline и выходит. Grace period Docker/orchestrator должен быть длиннее internal shutdown budget. `SIGKILL` не запускает cleanup.

`STOPSIGNAL` меняет signal image, но нестандартный выбор должен поддерживаться app/platform. Healthcheck не заменяет signal handling и не всегда влияет на restart вне Swarm/Compose policy.

## Проверка

```bash
docker inspect --format '{{.State.Pid}} {{.Config.Entrypoint}} {{.Config.Cmd}}' <container>
docker stop --time 30 <container>
docker top <container>
```

Integration test должен держать active request, послать TERM, проверить прекращение новых и bounded completion старого.

## Wrapper с правильным exec

```sh
#!/bin/sh
set -eu
# короткая проверка конфигурации
exec /service "$@"
```

Exec заменяет shell, поэтому приложение становится основным процессом. Если приложение создаёт children и не выполняет wait, `--init` помогает с reaping и signal forwarding, но не добавляет бизнес-протокол drain.

Проверьте остановку с активным запросом: после TERM прекращается приём, старый запрос завершается в пределах 20 секунд, а runtime даёт 30 секунд grace. Shell-form ENTRYPOINT и неверный wrapper могут привести к KILL, хотя handler shutdown написан корректно. В журнале должны быть времена начала/окончания остановки, а не только exit code.

## Источники

- [Dockerfile ENTRYPOINT](https://docs.docker.com/reference/dockerfile/#entrypoint)
- [docker container stop](https://docs.docker.com/reference/cli/docker/container/stop/)

## Проверь себя

1. Что делает exec в wrapper?
2. Заменяет ли --init graceful shutdown приложения?

<details>
<summary>Ориентиры для ответа</summary>

1. Заменяет shell процессом приложения, сохраняя PID и прямую доставку сигналов.
2. Нет, помогает process management, но app сама завершает управляемую работу.

</details>
