---
title: Arrays и slices
description: In-place traversal, compaction и indexing invariants.
tags: [algorithms, arrays]
updated: 2026-09-10
---

# Arrays и slices

## Что решает

Последовательный доступ, in-place transformation, compaction, partitioning и задачи, где порядок/индекс важнее lookup по key.

## Как распознать

Input contiguous, нужен один проход, разрешено менять массив, результат — prefix/segment или индекс. Часто достаточно read/write indices.

## Шаблон

```text
write = 0
for read in [0..n):
    if keep(a[read]):
        a[write] = a[read]
        write++
return a[:write]
```

Invariant: `a[:write]` уже содержит все сохранённые элементы из обработанного prefix в нужном порядке.

## Complexity

Один проход `O(n)` time, `O(1)` auxiliary space. Insert/delete в середине требует shift `O(n)`; append динамического массива — amortized `O(1)`.

## Типичные ошибки

Off-by-one, изменение length во время range, потеря backing-array alias semantics, удержание большого backing array маленьким subslice, integer overflow в index arithmetic.

## Несколько задач

- удалить duplicates из sorted slice in-place;
- move zeros с сохранением порядка;
- partition по predicate;
- rotate array;
- найти missing/duplicate при заданных constraints.
