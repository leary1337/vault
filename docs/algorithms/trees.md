---
title: Trees
description: Recursive invariants, BST и postorder aggregation.
tags: [algorithms, trees]
updated: 2026-09-10
---

# Trees

## Что решает

Hierarchical data, subtree aggregates, path queries, ordered lookup (BST) и divide-and-conquer recursion.

## Как распознать

У каждого node children/parent relation; answer node выводится из child answers; traversal order (pre/in/post) соответствует моменту обработки.

## Шаблон

```text
dfs(node):
    if node == nil: return base
    left = dfs(node.left)
    right = dfs(node.right)
    return combine(node, left, right)
```

Формулируйте contract функции: что именно она возвращает parent и как обновляет global answer.

## Complexity

Полный traversal `O(n)` time, `O(h)` call stack; balanced tree `h=O(log n)`, skewed `h=O(n)`. BST lookup зависит от balance.

## Типичные ошибки

Считать дерево balanced; неверный base для height/leaf; global mutable result не reset; overflow recursion на chain; проверять BST только parent-child вместо allowed range.

## Несколько задач

- max depth/balance;
- validate BST;
- lowest common ancestor;
- diameter;
- serialize/deserialize tree.
