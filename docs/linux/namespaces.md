---
title: Namespaces
description: Isolation views для PID, mount, network, user и других ресурсов.
tags: [linux, namespaces, containers]
updated: 2026-09-10
---

# Namespaces

Namespace изолирует view определённого global resource. Container обычно сочетает namespaces, cgroups, capabilities, seccomp и filesystem; namespace один не является security boundary.

| Namespace | Изолирует |
| --- | --- |
| PID | process ID tree; первый process становится PID 1 внутри namespace |
| mount | mount table/root view |
| network | interfaces, routes, ports, sockets, netfilter context |
| user | UID/GID mappings и capabilities scope |
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

PID 1 внутри namespace должен reap-ить orphan zombies и корректно обрабатывать signals. User namespace может дать root UID внутри при ограниченных host permissions, но kernel attack surface остаётся общей.

## Источники

- [namespaces(7)](https://man7.org/linux/man-pages/man7/namespaces.7.html)
- [user_namespaces(7)](https://man7.org/linux/man-pages/man7/user_namespaces.7.html)
