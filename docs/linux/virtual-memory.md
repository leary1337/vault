---
title: Virtual memory
description: Address spaces, pages, faults, mmap и copy-on-write.
tags: [linux, memory]
updated: 2026-09-10
---

# Virtual memory

Каждый process видит virtual address space. Page tables отображают virtual pages на physical frames либо отмечают, что page отсутствует/на disk. Поэтому virtual size не равен реально занятой RAM.

## Mappings

- anonymous memory: heap/stacks, zero-filled pages;
- file-backed mapping: executable, shared libraries, `mmap` files;
- shared memory: одна physical page видна нескольким processes;
- copy-on-write: после `fork` pages общие до первой записи.

Minor page fault разрешается без чтения storage (например, already cached page или COW mapping setup). Major fault требует I/O и намного дороже. Fault сам по себе нормален; важны rate, latency и pressure.

`mmap` резервирует/создаёт mapping, но physical allocation часто demand-paged. Overcommit позволяет обещать больше virtual memory, чем доступно; реальное касание может привести к reclaim/OOM.

## Диагностика

```bash
cat /proc/$PID/maps
cat /proc/$PID/smaps_rollup
vmstat 1
perf stat -p "$PID"
```

`VSZ` включает mappings/reservations и редко отражает leak. RSS — resident pages, но shared pages считаются в RSS каждого process; PSS делит shared pages пропорционально. `Private_Dirty`, anonymous/file split и fault rate объясняют рост лучше одного RSS.

## Источники

- [proc_pid_smaps(5)](https://man7.org/linux/man-pages/man5/proc_pid_smaps.5.html)
- [mmap(2)](https://man7.org/linux/man-pages/man2/mmap.2.html)
