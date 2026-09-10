---
title: Hash tables
description: Membership, counting, grouping и complement lookup.
tags: [algorithms, hash-tables]
updated: 2026-09-10
---

# Hash tables

## Что решает

Быстрый lookup по key, membership, frequencies, grouping, deduplication и запоминание ранее увиденного state.

## Как распознать

Вопросы «видели ли», «сколько раз», «есть ли complement», «сгруппировать по canonical key»; порядок key не нужен или восстанавливается отдельно.

## Шаблон

```text
state = map
for x in input:
    use state[x] or state[target-x]
    update state
```

Для sliding/counting удаляйте key при нулевом count, если размер map должен отражать distinct window.

## Complexity

Ожидаемо `O(n)` time и `O(k)` space, где k — distinct keys. Hash operations ожидаемо `O(1)`, но зависят от hash/equality и реализации.

## Типичные ошибки

Проверять complement после insert текущего элемента при запрете использовать один index дважды; считать iteration order; использовать mutable/non-comparable key; путать отсутствующий key с zero value; забывать normalize Unicode/case по условию.

## Несколько задач

- Two Sum;
- first non-repeating item;
- group anagrams по canonical representation;
- longest consecutive sequence;
- deduplicate events по stable ID.
