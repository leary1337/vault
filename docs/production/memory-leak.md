---
title: Memory leak
description: Поиск монотонно удерживаемой памяти и различение heap, native и cache growth.
tags: [production, memory-leak, go]
updated: 2026-10-06
---

# Memory leak

Heap leak в Go — объекты по-прежнему доступны из живых ссылок, хотя продукт больше не нуждается в них.

## Симптомы

После одинаковой нагрузки post-GC heap или RSS растёт от цикла к циклу и не возвращается к устойчивому plateau; время до OOM зависит от uptime.

## Возможные причины

Unbounded map/cache, забытые subscribers/timers, slice retaining большой backing array, queued work, goroutine leak с captured objects, unclosed response bodies, C/native allocation или intended cache без eviction.

## Что измерить

Post-GC live heap/RSS по времени и uptime, object count/bytes по type/stack, cache/queue cardinality (число разных значений или временных рядов), goroutines, native mappings и allocation-minus-free slope при стабильной нагрузке.

## Проверка гипотез

Сначала докажите устойчивый рост после warm-up и GC, затем различите heap/RSS. Снимите два comparable heap profiles через интервал и diff retained allocations. Идите от растущего type к retaining owner/lifecycle. Если heap стабилен, исследуйте mmap/native/page cache.

## Инструменты

Go `pprof` heap (`inuse_space`, `inuse_objects`), runtime metrics, `go tool pprof -base`, `/proc` maps/smaps, cgroup memory и controlled soak test.

## Как уменьшить ущерб

Ограничить offending cache/queue/input, отключить feature, уменьшить traffic, увеличить headroom (запас ресурса сверх обычной нагрузки) или выполнить rolling restart с controlled concurrency. Не объявляйте restart исправлением.

## Механизм причины

Найдите ownership (владение данными или ответственность за ресурс) path и отсутствующее lifecycle (кто создаёт, останавливает и освобождает ресурс) condition: кто добавляет, почему entry/object остаётся reachable и какое событие должно было удалить/закрыть его. Для native leak подтвердите allocation API и release path.

## Предотвращение

Bounded (с явным конечным пределом) collections с eviction/TTL, explicit `Close`/cancel ownership, soak/leak tests, profile regression, cardinality metrics и review lifetime каждого background goroutine/cache.

## Источник

- [Go profiling](https://go.dev/blog/pprof)

## Разбор с числами

Учебный soak: одинаковые циклы нагрузки, post-GC heap 100→150→200 MiB, cache entries 10k→20k→30k. Это свидетельство retained cache, не просто высокой скорости allocations. Иллюстративный diff inuse:

```text
flat      function
+96 MiB   ads.(*Cache).Put
+ 2 MiB   runtime.malg
```

Allocation stack показывает, где объекты появились, но не всегда где удерживаются. Проверяем owner map, expiry/eviction и размер ключей. `alloc_space` 10 GB при `inuse_space` 100 MB может означать churn без leak; snapshots сравниваем на сопоставимом прогретом состоянии.

Малый `slice := big[:10]` удерживает весь underlying array, даже если len=10. Копия нужных десяти элементов освобождает связь с большим массивом, если других ссылок нет. Restart удаляет ссылки временно, но новый код снова накопит карту; исправление проверяем plateau и ограниченным max size.

## Проверь себя

1. Почему GC не удаляет забытый cache?
2. Что различает inuse и alloc_space?

<details>
<summary>Ориентиры для ответа</summary>

1. Он достижим из живого владельца.
2. Текущее удержание и суммарное выделение за историю профиля.

</details>
