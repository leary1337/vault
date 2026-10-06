---
title: Hash tables
description: Membership, counting, grouping и complement lookup.
tags: [algorithms, hash-tables]
updated: 2026-10-06
---

# Hash tables

Хеш-таблица позволяет быстро вспомнить уже увиденное значение. В Go map нужен отдельный bool наличия, потому что ноль может быть настоящим значением.

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

## Сложность

Ожидаемо `O(n)` time и `O(k)` space, где k — distinct keys. Hash operations ожидаемо `O(1)`, но зависят от hash/equality и реализации.

## Типичные ошибки

Проверять complement после insert текущего элемента при запрете использовать один index дважды; считать iteration order; использовать mutable/non-comparable key; путать отсутствующий key с zero value; забывать normalize Unicode/case по условию.

## Несколько задач

- Two Sum;
- first non-repeating item;
- group anagrams по canonical representation;
- longest consecutive sequence;
- deduplicate events по stable ID.

## Two Sum: проверка до вставки

```go
func twoSum(a []int, target int) (int, int, bool) {
	seen := make(map[int]int)
	for i, value := range a {
		if j, ok := seen[target-value]; ok {
			return j, i, true
		}
		seen[value] = i
	}
	return 0, 0, false
}
```

Для [3,3], target6: первый3 не находит complement и сохраняется; второй находит index0, ответ(0,1,true). При единственном [3] ответ false. Если вставить до поиска, первый элемент ошибочно найдёт самого себя. Инвариант: map содержит только элементы с индексом меньше текущего.

Контракт предполагает отсутствие overflow target-value. При произвольных int границах нужно безопасное вычисление или заданный диапазон. Для анаграмм key должен быть канонической формой: частоты символов или отсортированная копия. «Похожий Unicode» не равен одинаковым code points; normalization выполняется по условию, не автоматически.

## Проверь себя

1. **Почему проверяем complement до вставки?**

   <details>
   <summary>Ответ</summary>

   Запрещено использовать один элемент дважды.

   </details>

2. **Можно отличить index0 от отсутствия по seen[key]==0?**

   <details>
   <summary>Ответ</summary>

   Нет; используйте значение и ok.

   </details>
