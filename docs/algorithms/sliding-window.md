---
title: Sliding window
description: Contiguous subarray/substring с incremental state.
tags: [algorithms, sliding-window]
updated: 2026-09-10
---

# Sliding window

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

## Complexity

`O(n)` time, потому что каждый элемент входит и выходит максимум один раз; space `O(k)` для window state или `O(1)`.

## Типичные ошибки

Путать fixed/variable window; обновлять answer в неверный момент; не удалять zero-count key; считать bytes вместо Unicode code points; использовать монотонный shrink при немонотонном условии.

## Несколько задач

- maximum sum fixed window;
- longest substring without repeats;
- minimum window containing multiset;
- longest segment с не более K distinct;
- shortest positive-sum subarray.
