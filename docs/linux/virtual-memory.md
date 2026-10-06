---
title: Virtual memory
description: Address spaces, pages, faults, mmap и copy-on-write.
tags: [linux, memory]
updated: 2026-10-06
---

# Virtual memory

Виртуальный адрес — адрес в пространстве процесса, а не прямой номер физической RAM. Pages получают физическую память и права через таблицы отображения.

Каждый process видит virtual address space. Page tables отображают virtual pages на physical frames либо отмечают, что page отсутствует/на disk. Поэтому virtual size не равен реально занятой RAM.

## Mappings

- anonymous memory: heap/stacks, zero-filled pages;
- file-backed mapping: executable, shared libraries, `mmap` files;
- shared memory: одна physical page видна нескольким processes;
- copy-on-write (общие страницы до первой записи, затем отдельная копия): после `fork` pages общие до первой записи.

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

## Обещанная память и реально используемая

Процесс может зарезервировать большой диапазон адресов, но касаться лишь небольшого числа страниц. Поэтому VSZ=8 ГиБ и RSS=200 МиБ не обязательно означают утечку 8 ГиБ. При первом касании страницы возникает нормальный fault; major fault требует ввода данных и способен повысить latency.

```mermaid
flowchart LR
    V["virtual page процесса A"] --> P["physical page"]
    W["virtual page процесса B"] --> P
    V -->|"после записи при COW"| N["отдельная physical page"]
```

После fork общая copy-on-write память разделяется при записи. Major/minor fault counters сравнивайте за интервал, а не абсолютное накопленное число. mmap файла не означает, что его данные уже прочитаны в RAM или устойчиво записаны на диск.

## Источники

- [proc_pid_smaps(5)](https://man7.org/linux/man-pages/man5/proc_pid_smaps.5.html)
- [mmap(2)](https://man7.org/linux/man-pages/man2/mmap.2.html)

## Проверь себя

1. Почему VSZ больше RSS?
2. Когда COW увеличивает физическую память?

<details>
<summary>Ориентиры для ответа</summary>

1. VSZ включает reserved/mapped address ranges; RSS только резидентные страницы.
2. При записи в общую страницу, когда нужна отдельная копия.

</details>
