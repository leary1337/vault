---
title: Binary search
description: Поиск границы монотонного predicate.
tags: [algorithms, binary-search]
updated: 2026-09-10
---

# Binary search

## Что решает

Lookup в sorted data и поиск первой/последней точки, где монотонный predicate меняет значение; также binary search on answer.

## Как распознать

Search space упорядочен, а predicate имеет форму `false...false,true...true` или обратную. Можно проверять candidate быстрее полного перебора.

## Шаблон

Первая позиция `predicate=true` на half-open `[lo, hi)`:

```text
while lo < hi:
    mid = lo + (hi-lo)/2
    if predicate(mid): hi = mid
    else: lo = mid + 1
return lo
```

После цикла проверьте, что `lo` внутри исходной области и predicate действительно true.

## Complexity

`O(log N)` predicate evaluations; итог `O(log N × cost(predicate))`, `O(1)` space. Sorting beforehand добавляет `O(n log n)`.

## Типичные ошибки

Смешать closed/half-open invariant; бесконечный loop из-за неверного mid/update; overflow `(lo+hi)/2`; вернуть insertion point как найденный element; predicate не монотонен; floating-point termination без iteration/epsilon policy.

## Несколько задач

- lower/upper bound;
- first bad version;
- rotated sorted array;
- minimum feasible capacity/speed;
- integer square root.
