---
title: Graphs
description: Representation, shortest paths, DAG и disjoint sets.
tags: [algorithms, graphs]
updated: 2026-09-10
---

# Graphs

## Что решает

Связи many-to-many: routing, dependencies, connectivity, prerequisites, networks и state spaces.

## Как распознать

Entities — vertices, relations/transitions — edges; path/cycle/component/order важнее hierarchy. Определите directed/undirected, weighted, negative weights, sparse/dense.

## Шаблон

- adjacency list для sparse graph;
- BFS для unweighted shortest path;
- Dijkstra с min-heap для non-negative weights;
- topological sort для DAG dependencies;
- Union-Find для incremental undirected connectivity.

## Complexity

BFS/DFS `O(V+E)`. Dijkstra adjacency list + heap `O((V+E) log V)`. Topological `O(V+E)`. Union-Find amortized почти constant (`O(α(V))`).

## Типичные ошибки

Забыть обратное edge в undirected graph; Dijkstra с negative weight; overflow distance; не отбросить stale heap entry; topology вернуть partial order при cycle; путать node label с dense index.

## Несколько задач

- network delay;
- dependency ordering;
- connected components;
- minimum spanning tree;
- evaluate paths/state transitions.
