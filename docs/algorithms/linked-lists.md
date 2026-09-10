---
title: Linked lists
description: Sentinel, reversal и slow/fast pointers.
tags: [algorithms, linked-lists]
updated: 2026-09-10
---

# Linked lists

## Что решает

Pointer rewiring, O(1) insertion with known node, cycle/middle detection и merge sorted streams.

## Как распознать

Random access не нужен; задача требует изменить links in-place; slow/fast pointers дают distance/cycle relation.

## Шаблон

Reverse:

```text
prev = nil; cur = head
while cur != nil:
    next = cur.next
    cur.next = prev
    prev = cur
    cur = next
return prev
```

Sentinel dummy упрощает delete/merge у head.

## Complexity

Traversal/reversal `O(n)` time, `O(1)` space. Access by index `O(n)`. Recursive reverse использует `O(n)` stack.

## Типичные ошибки

Потерять `next` до rewiring; не обновить head/tail; cycle вызвать infinite loop; сравнивать values вместо node identity; оставить broken prev/next в doubly list.

## Несколько задач

- reverse list;
- detect cycle и entry;
- merge sorted lists;
- remove Nth from end;
- LRU: hash map + doubly linked list.
