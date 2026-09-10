---
title: Stack
description: LIFO, matching delimiters и monotonic stack.
tags: [algorithms, stack]
updated: 2026-09-10
---

# Stack

## Что решает

Вложенные структуры, undo/path, iterative DFS, expression evaluation и nearest greater/smaller через monotonic stack.

## Как распознать

Последний открытый/добавленный элемент должен обрабатываться первым; нужно вернуться к parent; ответ для элемента зависит от ближайшего будущего, который вытесняет stack top.

## Шаблон

```text
for x in input:
    while stack not empty and should_pop(stack.top, x):
        resolve(pop, x)
    push x
```

Monotonic invariant: значения/indices в stack возрастают или убывают. Храните indices, если нужна distance.

## Complexity

Обычные push/pop `O(1)`. Monotonic pass `O(n)`: каждый элемент push/pop максимум раз; space `O(n)`.

## Типичные ошибки

Читать top пустого stack; хранить value вместо index; неверно обработать equality/duplicates; забыть unresolved elements после прохода; recursion stack overflow.

## Несколько задач

- valid parentheses;
- next greater element;
- daily temperatures;
- largest rectangle in histogram;
- normalize path / decode expression.
