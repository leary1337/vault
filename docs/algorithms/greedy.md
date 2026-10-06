---
title: Greedy
description: Локальный выбор с доказуемым exchange invariant.
tags: [algorithms, greedy]
updated: 2026-10-06
---

# Greedy

Жадный алгоритм делает необратимый локальный выбор. Чтобы он был правильным, нужно доказать, что выбор не мешает оптимальному решению.

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

## Сложность

Обычно `O(n log n)` из-за sorting и `O(n)` scan; space зависит от sort/state. Heap может дать dynamic greedy `O(n log n)`.

## Типичные ошибки

Выбрать интуитивный criterion без proof; применить coin greedy к произвольным denominations; забыть negative/zero cases; неверный tie-break; на самом деле требуется dynamic programming из-за зависимости будущих решений.

## Несколько задач

- maximum number of non-overlapping intervals (earliest finish);
- minimum arrows/meeting selection;
- Huffman coding;
- activity scheduling;
- MST (Kruskal/Prim с cut property).

## Встречи: выбирать ранний конец

Интервалы [1,3),[2,5),[3,4),[4,6). Сортируем по end: выбираем [1,3), выбираем [3,4), потому что start>=3, пропускаем [2,5), выбираем [4,6). Ответ3 встречи. Критерий самое раннее начало выбрал бы длинную [0,100) вместо многих коротких.

Доказательство обменом: первая встреча оптимального набора заканчивается не раньше выбранной greedy. Заменив её на самую рано заканчивающуюся, не перекрываем последующие встречи и не уменьшаем количество. Повторяем для оставшегося хвоста. Это объясняет выбор конца; аналогичное доказательство для «самой короткой встречи» не получается.

Монеты [1,3,4], сумма6: greedy берёт4+1+1 (три), оптимум3+3 (две). Нужна [динамика](dynamic-programming.md). Хорошие результаты на трёх тестах не доказательство; ищите контрпример прежде оптимизации. Если есть отрицательные цены, обязательные элементы или веса встреч, прежний greedy contract меняется.

## Проверь себя

1. **Почему ранний конец безопасен?**

   <details>
   <summary>Ответ</summary>

   Заменяет первую встречу оптимума, оставляя не меньше времени для остальных.

   </details>

2. **Почему coin greedy провален для [1,3,4] суммы6?**

   <details>
   <summary>Ответ</summary>

   Локально больший4 ведёт к трём монетам, а3+3 даёт две.

   </details>
