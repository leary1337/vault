---
title: Sorting
description: Comparator, stability, selection и domain-specific sort.
tags: [algorithms, sorting]
updated: 2026-09-10
---

# Sorting

## Что решает

Создаёт порядок, после которого доступны binary search, merge, two pointers, grouping и interval scan.

## Как распознать

Порядок превращает pair/global condition в локальную; ответ требует ranks; preprocessing `O(n log n)` дешевле quadratic scan.

## Шаблон

Определите strict weak ordering и tie-breakers:

```text
sort by primary ascending,
then secondary descending,
then stable unique id
```

После sort выполните linear scan с invariant.

## Complexity

Comparison sorting имеет lower bound `Ω(n log n)` в общем случае. Counting/radix sort могут быть linear при ограниченном integer/string domain и дополнительной памяти. In-place/stability зависят от algorithm/library.

## Типичные ошибки

Comparator не transitive; subtraction overflow; забыть stability requirement; потерять original indices; считать map iteration sorted; sort input неожиданно для caller; lexicographic vs numeric mismatch.

## Несколько задач

- merge intervals;
- sort by frequency с tie-break;
- largest concatenated number;
- kth element через selection vs full sort;
- external merge для данных больше RAM.
