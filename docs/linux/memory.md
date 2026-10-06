---
title: Memory и page cache
description: RSS, available memory, reclaim, swap и OOM.
tags: [linux, memory, production]
updated: 2026-10-06
---

# Memory и page cache

Linux использует свободную память для ускорения файлового ввода. Поэтому маленькое free нормально, пока память можно высвободить без тяжёлого ожидания.

Linux использует свободную RAM как page cache для file data. Малое `free` не означает exhaustion; `MemAvailable`, reclaim (освобождение или вытеснение страниц для получения памяти) pressure, swap activity и application latency информативнее.

## Категории

- anonymous: heap/stacks; reclaim обычно требует swap или kill;
- file/page cache: clean pages можно отбросить и перечитать, dirty нужно writeback (запись изменённых страниц на storage);
- slab/kernel memory: dentries, inodes, network и другие objects;
- shared/tmpfs и socket buffers;
- cgroup-accounted subsets.

Process RSS показывает resident mappings, но shared pages double-count между processes. PSS полезнее для распределения shared cost. Go heap metrics не включают весь RSS: stacks, runtime metadata, mmap, C libraries и page residency отличаются.

## Pressure и OOM

Reclaim сканирует pages, writeback и swap могут поднять latency до OOM. OOM killer выбирает victim по score/constraints; в cgroup v2 hard `memory.max` может вызвать cgroup-local OOM. `memory.events` различает `high`, `max`, `oom`, `oom_kill`.

```bash
free -h
vmstat 1
cat /proc/meminfo
cat /proc/pressure/memory
cat /proc/$PID/smaps_rollup
dmesg -T | grep -i -E 'oom|killed process'
```

Не очищайте page cache как обычное «лечение»: это ухудшает hit rate и скрывает root cause. Сопоставляйте allocation rate, RSS/anon, faults, reclaim/PSI, swap, cgroup events и workload.

## Пример различения cache и утечки

```text
MemFree:        500000 kB
MemAvailable: 8000000 kB
Cached:       7000000 kB
```

Это иллюстрация: мало полностью свободной RAM, но оценка доступной памяти велика. Иной случай — рост anonymous памяти, swap/reclaim и memory PSI при падающем available: приложение уже испытывает давление.

RSS двух процессов по 1 ГиБ не обязательно означает 2 ГиБ уникальной памяти: часть pages общая. PSS распределяет shared pages между владельцами. Контейнерный `memory.current` включает свои категории cache/kernel; сравнивайте с breakdown, не только с Go heap.

`oom_kill` — подтверждение убийства OOM, но exit=137 сам по себе означает SIGKILL и может быть результатом stop timeout, а не нехватки памяти.

## Источники

- [proc_meminfo(5)](https://man7.org/linux/man-pages/man5/proc_meminfo.5.html)
- [PSI](https://docs.kernel.org/accounting/psi.html)

## Проверь себя

1. Почему low free не равно OOM?
2. Почему exit 137 не доказывает OOM?

<details>
<summary>Ориентиры для ответа</summary>

1. Часть cache можно reclaim; важны available, pressure и реальные limits.
2. SIGKILL мог быть отправлен по другой причине; нужны events и logs.

</details>
