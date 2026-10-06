---
title: Namespaces
description: Isolation views для PID, mount, network, user и других ресурсов.
tags: [linux, namespaces, containers]
updated: 2026-10-06
---

# Namespaces

Namespace даёт процессу своё представление ресурса: список PID, сеть или mounts. Он не создаёт отдельное ядро и сам не ограничивает расход памяти/CPU.

Namespace изолирует view определённого global resource. Container обычно сочетает namespaces, cgroups, capabilities (отдельные полномочия Linux вместо всех полномочий root), seccomp (ограничение разрешённых системных вызовов) и filesystem; namespace один не является security boundary.

| Namespace | Изолирует |
| --- | --- |
| PID | process ID tree; первый process становится PID 1 внутри namespace |
| mount | mount table/root view |
| network | interfaces, routes, ports, sockets, netfilter context |
| user | UID/GID mappings и capabilities scope (область измерения: host, cgroup или process) |
| UTS | hostname/domain name |
| IPC | SysV IPC/POSIX message queues |
| cgroup | view cgroup paths |
| time | некоторые clocks offsets |

`clone/unshare/setns` создают/входят в namespaces. `/proc/$PID/ns/*` содержит namespace handles; одинаковый inode означает общий namespace этого типа.

```bash
ls -l /proc/$PID/ns
nsenter -t "$PID" -m -u -i -n -p -- sh
unshare --user --map-root-user --mount --pid --fork sh
```

`nsenter` меняет diagnostic context и требует privileges; не запускайте модифицирующие команды без понимания target namespace.

PID 1 внутри namespace должен reap (забрать status завершённого дочернего process)-ить orphan zombies и корректно обрабатывать signals. User namespace может дать root UID внутри при ограниченных host permissions, но kernel attack surface остаётся общей.

## Сравнить, общая ли сеть

```bash
readlink /proc/"$PID"/ns/net
readlink /proc/1/ns/net
```

Вывод вида `net:[4026531992]` — identity network namespace. Одинаковый inode означает общий namespace. В контейнере `localhost` относится к его namespace; два containers в одном Kubernetes Pod обычно разделяют сеть, а два обычных Docker containers — нет.

User namespace может сопоставить UID 0 внутри с непривилегированным UID на host. Это снижает часть полномочий, но атаки на общее ядро остаются возможны. Для защиты нужны capabilities/seccomp, ограничения mounts и обновлённое ядро. `nsenter` переносит диагностическую команду в другой контекст: перед изменением всегда проверьте целевой PID.

## Источники

- [namespaces(7)](https://man7.org/linux/man-pages/man7/namespaces.7.html)
- [user_namespaces(7)](https://man7.org/linux/man-pages/man7/user_namespaces.7.html)

## Проверь себя

1. Чем cgroup отличается от namespace?
2. Что означает localhost у двух containers одного Pod?

<details>
<summary>Ориентиры для ответа</summary>

1. Cgroup ограничивает/учитывает ресурсы; namespace меняет видимость/идентичность.
2. Общее loopback-пространство Pod; порты также общие и могут конфликтовать.

</details>
