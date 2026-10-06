---
title: File descriptors
description: FD tables, open file descriptions, limits и leaks.
tags: [linux, file-descriptors]
updated: 2026-10-06
---

# File descriptors

FD — номер открытого ресурса в таблице процесса. За ним может быть файл, соединение или pipe; освобождать его нужно при завершении владельца.

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

## Номер и открытый объект — не одно и то же

После `dup(fd)` два номера указывают на одну open file description и разделяют offset. Чтение через первый FD сдвигает позицию для второго. После `close` номер может быстро использоваться для другого файла, поэтому хранить «старый FD как identity» опасно.

Пример диагностики:

```bash
find /proc/"$PID"/fd -maxdepth 1 -type l | wc -l
lsof -p "$PID" +L1
```

Первая команда считает текущие descriptors, вторая ищет открытые удалённые файлы. Числа и имена зависят от процесса. Если log удалили, но FD остался открыт, место освободится только после закрытия. `EMFILE` обычно относится к лимиту процесса, `ENFILE` — к системному лимиту.

## Источники

- [open(2)](https://man7.org/linux/man-pages/man2/open.2.html)
- [proc_pid_fd(5)](https://man7.org/linux/man-pages/man5/proc_pid_fd.5.html)

## Проверь себя

1. Почему rm большого log может не освободить диск?
2. Чем dup отличается от повторного open?

<details>
<summary>Ориентиры для ответа</summary>

1. Открытый FD держит inode/data до закрытия.
2. Dup разделяет open file description/offset; новый open обычно создаёт отдельную позицию.

</details>
