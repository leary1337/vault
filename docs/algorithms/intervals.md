---
title: Intervals
description: Merge, overlap, sweep line и endpoint semantics.
tags: [algorithms, intervals]
updated: 2026-09-10
---

# Intervals

## Что решает

Merge overlaps, scheduling conflicts, coverage, resource concurrency и line sweep events.

## Как распознать

Input состоит из start/end, важен overlap/union; sorting по start превращает global problem в сравнение с последним merged interval.

## Шаблон

```text
sort by (start, end)
for interval:
    if result empty or interval.start > result.last.end:
        append interval
    else:
        result.last.end = max(last.end, interval.end)
```

Условие меняется для closed `[a,b]` и half-open `[a,b)`: touching intervals могут overlap или нет по domain.

## Complexity

Sorting `O(n log n)`, merge `O(n)`, output `O(n)`. Уже sorted input — `O(n)`.

## Типичные ошибки

Не определить endpoint semantics/timezone; сортировать только start без нужного tie-break; mutate aliased input неожиданно; overflow при event comparator; обрабатывать equal start/end в неверном порядке sweep line.

## Несколько задач

- merge intervals;
- insert interval;
- meeting rooms count;
- total covered length;
- employee free time.
