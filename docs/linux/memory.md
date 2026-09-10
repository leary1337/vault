---
title: Memory и page cache
description: RSS, available memory, reclaim, swap и OOM.
tags: [linux, memory, production]
updated: 2026-09-10
---

# Memory и page cache

Linux использует свободную RAM как page cache для file data. Малое `free` не означает exhaustion; `MemAvailable`, reclaim pressure, swap activity и application latency информативнее.

## Категории

- anonymous: heap/stacks; reclaim обычно требует swap или kill;
- file/page cache: clean pages можно отбросить и перечитать, dirty нужно writeback;
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

## Источники

- [proc_meminfo(5)](https://man7.org/linux/man-pages/man5/proc_meminfo.5.html)
- [PSI](https://docs.kernel.org/accounting/psi.html)
