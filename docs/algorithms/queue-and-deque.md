---
title: Queue и deque
description: FIFO traversal и monotonic window extrema.
tags: [algorithms, queue, deque]
updated: 2026-09-10
---

# Queue и deque

## Что решает

FIFO scheduling, BFS по уровням и sliding-window min/max с monotonic deque.

## Как распознать

Объекты нужно обрабатывать в порядке обнаружения; shortest path в unweighted graph; window удаляет слева и добавляет справа; нужен лучший candidate окна.

## Шаблон

```text
queue = [start]; mark visited
while queue not empty:
    v = pop_front()
    for next in neighbors(v):
        if unseen: mark; push_back(next)
```

Для window maximum deque хранит indices с убывающими values, удаляя вышедшие indices слева и меньшие values справа.

## Complexity

BFS `O(V+E)` time, `O(V)` space. Monotonic deque `O(n)` time, `O(k)` space. Array `remove first` может быть `O(n)`; используйте head index/ring buffer.

## Типичные ошибки

Mark visited после dequeue и добавить node много раз; забыть границы level; хранить stale window indices; использовать slice reslicing, удерживая большие references; unbounded production queue.

## Несколько задач

- level-order tree traversal;
- shortest path in grid;
- number of islands BFS;
- sliding window maximum;
- recent requests ring buffer.
