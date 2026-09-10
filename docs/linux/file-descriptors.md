---
title: File descriptors
description: FD tables, open file descriptions, limits и leaks.
tags: [linux, file-descriptors]
updated: 2026-09-10
---

# File descriptors

File descriptor — малое целое в per-process table, ссылающееся на kernel open file description/object. Files, sockets, pipes, eventfd, epoll и многие другие interfaces представлены FD.

`open()` создаёт open file description со file offset/status flags и descriptor. `dup()` и после `fork()` descriptors могут ссылаться на одно description и разделять offset/status flags. Descriptor flags вроде `FD_CLOEXEC` принадлежат самому FD.

Всегда создавайте internal descriptors с close-on-exec (`O_CLOEXEC`, `SOCK_CLOEXEC`, `accept4`) атомарно, иначе concurrent `fork+exec` может унаследовать secret/socket. Закрывайте FD по всем error paths.

## Limits и symptoms

`RLIMIT_NOFILE` ограничивает process; system-wide limits/allocated file handles — отдельно. При exhaustion `open/socket/accept` возвращают `EMFILE` или `ENFILE`, health/logging тоже могут перестать работать.

```bash
ls -l /proc/$PID/fd
lsof -p "$PID"
cat /proc/$PID/limits
cat /proc/sys/fs/file-nr
```

Рост FD разбейте по type/target. Много sockets может быть нормальным pool/traffic или leak; сопоставьте с `ss`, connection states и rate. Увеличение limit маскирует leak, если count продолжает расти.

Удалённый файл остаётся занимать disk, пока открыт descriptor; `lsof +L1` помогает найти such files.

## Источники

- [open(2)](https://man7.org/linux/man-pages/man2/open.2.html)
- [proc_pid_fd(5)](https://man7.org/linux/man-pages/man5/proc_pid_fd.5.html)
