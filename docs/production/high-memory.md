---
title: High memory
description: Диагностика heap, RSS, page cache, mmap и cgroup memory pressure.
tags: [production, memory, go]
updated: 2026-10-06
---

# High memory

Память процесса включает Go heap, stacks, runtime, native/mmap и другие области; метрика контейнера может учитывать ещё файловый кэш.

## Симптомы

Working set/RSS приближается к limit, растут reclaim/PSI/OOM events, GC учащается или container получает OOMKill. Go heap metric может быть заметно меньше process memory.

## Возможные причины

Рост live heap, временный burst, large buffers/caches, goroutine stacks, mmap/native allocations, page cache, memory fragmentation, telemetry (диагностические данные: метрики, логи и traces) queues или неверный limit.

## Что измерить

RSS/working set, cgroup `memory.current/events/stat`, heap live/in-use/idle/released, allocation rate, GC frequency, goroutines/stacks, page cache и relation к traffic/data size.

## Проверка гипотез

Определите компонент памяти: Go heap vs stacks vs mapped/native vs file cache. Сравните после GC и между versions. Heap profiles `inuse_space` показывают удерживаемые объекты, `alloc_space` — churn; один snapshot не доказывает leak. Проверьте memory limit/GOMEMLIMIT и OOM event timeline.

## Инструменты

cgroup v2 files, `memory.stat`, `/proc/<pid>/smaps_rollup`, `pmap`, Go runtime metrics/`pprof`, Kubernetes events и node PSI.

## Как уменьшить ущерб

Остановить admission/large jobs, уменьшить bounded (с явным конечным пределом) caches/batches, rollback (отмена локальной транзакции или возврат старой версии), traffic shift или аккуратно увеличить memory при наличии capacity. Rolling restart временно снимает pressure, но сохраняйте profile/evidence сначала.

## Механизм причины

Классифицируйте: пропорциональный legitimate working set, allocation burst, retained object graph, native mapping или resource limit mismatch. Подтвердите timeline и controlled test.

## Предотвращение

Memory budgets на caches/queues, bounded payload/batch, load tests до steady state, heap/profile access, requests/limits по измерениям и alerts на PSI/OOM/budget trend, а не только процент.

## Разбор с числами

Учебные данные: `memory.current=900 MiB`, Go live heap=200 MiB, stack=30 MiB. Нельзя назвать недостающие 670 MiB heap leak. Смотрим cgroup `memory.stat` (anon/file), process smaps, native buffers и метрики runtime; суммы могут иметь разные границы учёта.

Если live heap стабилен после GC, но file memory растёт во время загрузки файлов, гипотеза удержания Go map слабее гипотезы page cache. Если live heap растёт вместе с cardinality (число разных значений или временных рядов) cache, профиль inuse и owner карты дают другую картину. GOMEMLIMIT — мягкая цель управляемой Go памяти, не предел RSS/container; native/mmap и часть расходов вне его границы.

Для limit 1 GiB цель Go ниже limit оставляет запас stacks/runtime/native и временного пика, величину измеряем. Слишком низкая цель при большом живом наборе повышает GC work и не делает reachable объекты удаляемыми. [cgroup v2](https://docs.kernel.org/admin-guide/cgroup-v2.html).

## Проверь себя

1. Почему GOMEMLIMIT не гарантирует отсутствие OOM?
2. Когда смотреть native/file память?

<details>
<summary>Ориентиры для ответа</summary>

1. Это мягкая цель Go memory, не полный жёсткий лимит контейнера.
2. Когда heap стабилен, а общий учёт памяти растёт.

</details>
