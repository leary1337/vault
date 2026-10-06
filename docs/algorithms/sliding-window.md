---
title: Sliding window
description: Contiguous subarray/substring с incremental state.
tags: [algorithms, sliding-window]
updated: 2026-10-06
---

# Sliding window

Скользящее окно — непрерывный участок, который расширяют справа и уменьшают слева. Вы не пересчитываете его состояние заново после каждого шага.

## Что решает

Longest/shortest contiguous segment с условием, fixed-size aggregate и substring frequency problems.

## Как распознать

Ответ — contiguous interval; state можно обновить добавлением right и удалением left; условие имеет монотонность для shrink. При отрицательных числах многие sum-window assumptions ломаются.

## Шаблон

```text
left = 0
for right in [0..n):
    add(a[right])
    while window invalid:
        remove(a[left]); left++
    update answer from [left..right]
```

Для minimum-valid window обычно обновляйте ответ до shrink или внутри цикла, пока условие ещё выполнено.

## Сложность

`O(n)` time, потому что каждый элемент входит и выходит максимум один раз; space `O(k)` для window state или `O(1)`.

## Типичные ошибки

Путать fixed/variable window; обновлять answer в неверный момент; не удалять zero-count key; считать bytes вместо Unicode code points; использовать монотонный shrink при немонотонном условии.

## Несколько задач

- maximum sum fixed window;
- longest substring without repeats;
- minimum window containing multiset;
- longest segment с не более K distinct;
- shortest positive-sum subarray.

## Самая длинная строка без повторов

Для abba: a → окно a длиной1; b → ab длиной2; второй b требует убрать старый b и a, left=2, окно b; a → ba длиной2. Ответ2. Когда a повторяется, его прежняя позиция0 уже вне окна: left нельзя откатить к1. Инвариант: текущий участок не содержит повторов, left только растёт.

Для минимального отрезка суммы>=S обычное уменьшение работает на неотрицательных числах. При [3,-2,5], S=5 удаление левого3 меняет сумму с6 до3, затем удаление -2 увеличивает её до5: условие не монотонно. Нужны prefix sums и монотонная deque либо другой метод, а не тот же while.

Фиксированное окно суммы k поддерживается прибавлением входящего и вычитанием уходящего числа. Окно уникальных символов требует счётчиков/last positions. В Go string byte-index и rune-position различаются: определите, считаются байты, Unicode code points или пользовательские grapheme clusters.

## Проверь себя

1. **Почему left=max(left,last+1)?**

   <details>
   <summary>Ответ</summary>

   Повтор вне текущего окна не должен двигать границу назад.

   </details>

2. **Почему отрицательные числа опасны для sum-window?**

   <details>
   <summary>Ответ</summary>

   Удаление элемента может увеличить сумму, исчезает нужная монотонность.

   </details>
