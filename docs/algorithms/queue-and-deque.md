---
title: Queue и deque
description: FIFO traversal и monotonic window extrema.
tags: [algorithms, queue, deque]
updated: 2026-10-06
---

# Queue и deque

Очередь обрабатывает элементы в порядке добавления. Deque разрешает добавление и удаление с обеих сторон; в монотонной deque остаются только полезные кандидаты окна.

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

## Сложность

BFS `O(V+E)` time, `O(V)` space. Monotonic deque `O(n)` time, `O(k)` space. Array `remove first` может быть `O(n)`; используйте head index/ring buffer.

## Типичные ошибки

Mark visited после dequeue и добавить node много раз; забыть границы level; хранить stale window indices; использовать slice reslicing, удерживая большие references; unbounded production queue.

## Несколько задач

- level-order tree traversal;
- shortest path in grid;
- number of islands BFS;
- sliding window maximum;
- recent requests ring buffer.

## Максимум окна k=3

Вход[1,3,-1,-3,5]. После первых трёх deque индексов[1,2]: value3 вытеснил1, максимум3. После -3 стек кандидатов[1,2,3], максимум3. При5 индекс1 выходит за окно, значения -3,-1 слабее нового5 и удаляются справа; deque[4], максимум5. Ответ[3,3,5].

Старший более слабый кандидат бесполезен: новый больше и выйдет из окна позже. Это доказательство каждого pop справа. Каждый индекс входит/выходит максимум один раз, O(n). Равенства можно удалять или сохранять в зависимости от нужного tie-breaker; для одного значения maximum оба варианта допустимы.

В Go простая BFS queue с head index избегает копирования при каждом pop. Если хранит pointers, очищайте обработанные элементы и периодически уплотняйте/используйте ring buffer, чтобы не удерживать все ссылки. Изменение q=q[1:] не гарантирует освобождение backing array.

## Проверь себя

1. **Почему удаляем меньшие справа?**

   <details>
   <summary>Ответ</summary>

   Новый кандидат лучше и переживёт их по сроку окна.

   </details>

2. **Почему pop-front с копированием может сделать BFS дорогим?**

   <details>
   <summary>Ответ</summary>

   Сдвигает оставшуюся очередь на каждом шаге, суммарно возможна квадратичная работа.

   </details>
