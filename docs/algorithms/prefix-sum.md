---
title: Prefix sum
description: Быстрые суммы диапазонов и balance state.
tags: [algorithms, prefix-sum]
updated: 2026-09-10
---

# Prefix sum

## Что решает

Много range-sum queries, subarray sum/count, cumulative balance и перевод interval updates в difference array.

## Как распознать

Нужно repeatedly агрегировать contiguous prefix/range; операция имеет обратную/комбинируемую форму; subarray property выражается разностью двух prefixes.

## Шаблон

```text
prefix[0] = 0
for i in [0..n): prefix[i+1] = prefix[i] + a[i]
sum(l, r exclusive) = prefix[r] - prefix[l]
```

Для count subarrays с sum K храните frequencies предыдущих prefixes: текущему `p` нужны `p-K`.

## Complexity

Build `O(n)` time/space, range query `O(1)`. Streaming variant использует `O(k)` map. 2D prefix даёт `O(rows×cols)` build и `O(1)` rectangle sum.

## Типичные ошибки

Смешать inclusive/exclusive bounds; забыть initial prefix 0; insert current prefix до lookup и ошибиться на K=0; integer overflow; пытаться использовать обычный sliding window с negative numbers.

## Несколько задач

- range sum queries;
- count subarrays sum K;
- longest equal zeros/ones через balance;
- product except self через prefix/suffix;
- range additions difference array.
