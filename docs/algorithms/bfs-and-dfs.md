---
title: BFS и DFS
description: Traversal, reachability, components и shortest unweighted path.
tags: [algorithms, traversal]
updated: 2026-09-10
---

# BFS и DFS

## Что решает

Reachability, connected components, flood fill, cycle/topological analysis и paths. BFS на unweighted graph находит shortest number of edges; DFS удобен для structure/postorder.

## Как распознать

Есть states и transitions/neighbors; нужно посетить reachable set или найти путь. State может быть implicit: grid cell, word, configuration.

## Шаблон

BFS использует queue и mark on enqueue. DFS использует recursion или explicit stack; для cycle в directed graph нужны состояния unseen/visiting/done.

## Complexity

Adjacency-list traversal `O(V+E)` time, `O(V)` visited/frontier. Grid `O(rows×cols)`. Если neighbors генерируются дорого, включайте их стоимость.

## Типичные ошибки

Не включить весь state в visited key; mark после dequeue/push и получить duplicates; DFS recursion overflow; применять BFS к weighted edges; забыть disconnected components; mutate input, когда это запрещено.

## Несколько задач

- islands/flood fill;
- shortest grid path;
- clone graph;
- course schedule/cycle;
- multi-source BFS от всех источников.
