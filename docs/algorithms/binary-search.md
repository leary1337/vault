---
title: Binary search
description: Поиск границы монотонного predicate.
tags: [algorithms, binary-search]
updated: 2026-10-06
---

# Binary search

Двоичный поиск каждый раз отбрасывает половину допустимых ответов. Он работает, если условие меняется в одном направлении: сначала false, потом true.

## Что решает

Lookup в отсортированные данные и поиск первой/последней точки, где монотонный predicate меняет значение; также binary search on answer.

## Как распознать

Search space упорядочен, а predicate имеет форму `false...false,true...true` или обратную. Можно проверять candidate быстрее полного перебора.

## Шаблон

Первая позиция `predicate=true` на полуоткрытый `[lo, hi)`:

```text
while lo < hi:
    mid = lo + (hi-lo)/2
    if predicate(mid): hi = mid
    else: lo = mid + 1
return lo
```

После цикла проверьте, что `lo` внутри исходной области и predicate действительно true.

## Сложность

`O(log N)` predicate evaluations; итог `O(log N × cost(predicate))`, `O(1)` space. Sorting beforehand добавляет `O(n log n)`.

## Типичные ошибки

Смешать closed/полуоткрытый invariant; бесконечный loop из-за неверного mid/update; overflow `(lo+hi)/2`; вернуть insertion point как найденный element; predicate не монотонен; floating-point termination без iteration/epsilon policy.

## Несколько задач

- lower/upper bound;
- first bad version;
- rotated sorted array;
- minimum feasible capacity/speed;
- integer square root.

## Трасса lower bound

Для a=[1,3,3,7], target=3:

| lo | hi (не включён) | mid | Решение |
| --- | --- | --- | --- |
| 0 | 4 | 2 | a[2]>=3 → hi=2 |
| 0 | 2 | 1 | a[1]>=3 → hi=1 |
| 0 | 1 | 0 | a[0]<3 → lo=1 |

Ответ 1. До lo все элементы меньше target; начиная с hi все проверенные справа подходят. Возвращённая позиция может равняться len(a), поэтому для проверки наличия нужен i<len(a) && a[i]==target.

Поиск по ответу: минимальная вместимость машины для перевозки грузов в D рейсов. Predicate «вместимость C достаточна» монотонен: увеличение C не делает допустимую перевозку невозможной. Если проверка C требует O(n), итог O(n log range), не просто O(log n). Верхняя граница и сумма грузов должны помещаться в тип.

## Проверь себя

1. **Почему hi=len(a) безопасен?**

   <details>
   <summary>Ответ</summary>

   Это исключённая граница, a[hi] не читается; ответ может обозначать вставку после конца.

   </details>

2. **Что ломает поиск по ответу?**

   <details>
   <summary>Ответ</summary>

   Немонотонный predicate или неверные границы/переполнение проверки.

   </details>
