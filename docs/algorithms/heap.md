---
title: Heap
description: Dynamic minimum/maximum, Top K и k-way merge.
tags: [algorithms, heap]
updated: 2026-09-10
---

# Heap

## Что решает

Repeated extract-min/max, bounded Top K, scheduler priority, k-way merge и streaming median с двумя heaps.

## Как распознать

Нужен лучший элемент после динамических insertions; сортировать всё избыточно; одновременно важны только K candidates.

## Шаблон

Top K largest держит min-heap размера K:

```text
for x in input:
    push x
    if heap.size > K: pop minimum
```

После прохода heap содержит K largest, но не обязательно sorted.

## Complexity

Build heap `O(n)`, push/pop `O(log k)`, peek `O(1)`. Top K — `O(n log k)` time, `O(k)` space; full output sorting добавит `O(k log k)`.

## Типичные ошибки

Выбрать max-heap вместо min-heap для bounded top largest; считать internal array sorted; mutate priority без fix; comparator overflow через subtraction; не определить tie-breaker/stability.

## Несколько задач

- Kth largest;
- merge K sorted lists;
- top K frequent;
- meeting-room scheduler;
- running median.
