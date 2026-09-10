---
title: Greedy
description: Локальный выбор с доказуемым exchange invariant.
tags: [algorithms, greedy]
updated: 2026-09-10
---

# Greedy

## Что решает

Optimization, где локально лучший безопасный выбор можно доказуемо включить в некоторое optimal solution: intervals, scheduling, spanning tree, coding.

## Как распознать

После сортировки выбор необратим; есть exchange argument/cut property; future state сводится к малому invariant. Совпадение с примерами не является доказательством.

## Шаблон

```text
sort candidates by proven priority
state = empty
for candidate:
    if feasible with state:
        choose; update state
```

Доказательство: замените первый отличающийся выбор optimal solution на greedy choice и покажите, что feasibility/quality не ухудшились.

## Complexity

Обычно `O(n log n)` из-за sorting и `O(n)` scan; space зависит от sort/state. Heap может дать dynamic greedy `O(n log n)`.

## Типичные ошибки

Выбрать интуитивный criterion без proof; применить coin greedy к произвольным denominations; забыть negative/zero cases; неверный tie-break; на самом деле требуется dynamic programming из-за зависимости будущих решений.

## Несколько задач

- maximum number of non-overlapping intervals (earliest finish);
- minimum arrows/meeting selection;
- Huffman coding;
- activity scheduling;
- MST (Kruskal/Prim с cut property).
