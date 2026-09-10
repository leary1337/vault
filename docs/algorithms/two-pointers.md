---
title: Two pointers
description: Linear scan с двумя монотонно движущимися индексами.
tags: [algorithms, two-pointers]
updated: 2026-09-10
---

# Two pointers

## Что решает

Pairs в sorted data, in-place compaction, partition и сравнение последовательностей без nested full scan.

## Как распознать

Данные sorted или можно sort; при изменении суммы/условия понятно, какой pointer двигать; каждый pointer движется только вперёд/к центру.

## Шаблон

```text
left = 0; right = n-1
while left < right:
    v = f(a[left], a[right])
    if v == target: handle
    else if v < target: left++
    else: right--
```

Доказательство опирается на sorted order: движение отбрасывает целый набор невозможных пар.

## Complexity

После сортировки scan `O(n)` time, `O(1)` space. Если sort не дан, общая стоимость обычно `O(n log n)` и возможна потеря исходных indices.

## Типичные ошибки

Применять к unsorted data без доказательства; `left <= right` при выборе двух разных элементов; пропуск duplicate handling; overflow суммы; не обновить pointer во всех branches.

## Несколько задач

- pair sum в sorted array;
- remove duplicates in-place;
- container with most water;
- merge двух sorted arrays;
- palindrome после normalization.
