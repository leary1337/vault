---
title: Complexity
description: Time, space, amortized analysis и реальные ограничения.
tags: [algorithms, complexity]
updated: 2026-09-10
---

# Complexity

Big O задаёт асимптотическую верхнюю границу роста, отбрасывая constants и lower-order terms. Для практического выбора также важны input limits, allocations, cache locality и worst-case latency.

## Частые классы

| Complexity | При росте n | Пример |
| --- | --- | --- |
| `O(1)` | constant | index access |
| `O(log n)` | медленно растёт | binary search |
| `O(n)` | линейно | один проход |
| `O(n log n)` | типичная сортировка | comparison sort |
| `O(n²)` | пары | nested scan |
| `O(2^n)`, `O(n!)` | экспонента | subset/permutation search |

Всегда называйте переменные: graph BFS — `O(V+E)`, а не просто `O(n)`. Space включает auxiliary memory; input/output обычно оговаривают отдельно. Recursion stack тоже память.

## Amortized

Append динамического массива иногда копирует `O(n)`, но последовательность appends обычно имеет amortized `O(1)`. Hash table ожидаемо `O(1)` для lookup при хорошей hash/distribution, worst case может быть хуже.

## Как проверять

- Сколько раз каждый элемент входит/выходит из структуры?
- Вложенные loops действительно независимы или два указателя суммарно проходят n?
- Сортировка уже дана или стоит `O(n log n)`?
- Значения помещаются в integer при sum/multiplication?
- Может ли adversarial input ухудшить recursion/hash?

Complexity — свойство алгоритма и assumptions, не одной строки кода.
