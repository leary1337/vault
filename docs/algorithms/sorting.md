---
title: Sorting
description: Comparator, stability, selection и domain-specific sort.
tags: [algorithms, sorting]
updated: 2026-10-06
---

# Sorting

Сортировка создаёт порядок, который упрощает поиск и сравнение. Comparator должен описывать согласованный порядок; сортировка не исправляет противоречивые сравнения.

## Что решает

Создаёт порядок, после которого доступны binary search, merge, two pointers, grouping и interval scan.

## Как распознать

Порядок превращает pair/global condition в локальную; ответ требует ranks; preprocessing `O(n log n)` дешевле quadratic scan.

## Шаблон

Определите strict weak ordering и tie-breakers:

```text
sort by primary ascending,
then secondary descending,
then stable unique id
```

После sort выполните linear scan с invariant.

## Сложность

Comparison sorting имеет lower bound `Ω(n log n)` в общем случае. Counting/radix sort могут быть linear при ограниченном integer/string domain и дополнительной памяти. In-place/stability зависят от algorithm/library.

## Типичные ошибки

Comparator не transitive; subtraction overflow; забыть stability requirement; потерять original indices; считать map iteration sorted; sort input неожиданно для caller; lexicographic vs numeric mismatch.

## Несколько задач

- merge intervals;
- sort by frequency с tie-break;
- largest concatenated number;
- kth element через selection vs full sort;
- external merge для данных больше RAM.

## Равные ключи и стабильность

Записи [(Анна,2),(Борис,1),(Вера,2)]. Stable sort по score даёт Борис,Анна,Вера: равные сохраняют входной порядок. Обычный sort не обещает Анна перед Верой. Если нужен одинаковый ответ независимо от входа, используйте score затем unique id; stability и tie-breaker решают разные задачи.

```go
type PersonScore struct {
	ID    int
	Score int
}

func sortScores(a []PersonScore) {
	slices.SortFunc(a, func(x, y PersonScore) int {
		if c := cmp.Compare(x.Score, y.Score); c != 0 {
			return c
		}
		return cmp.Compare(x.ID, y.ID)
	})
}
```

Imports: cmp,slices; API доступны с Go1.21. Не пишите x.Score-y.Score: overflow может поменять знак. a<b и b<c обязаны согласовываться с a<c; comparator с random/time зависит от внешнего состояния и нарушает контракт. slices.SortFunc меняет input. Для float NaN нужен определённый порядок, поэтому произвольный comparator на < без политики NaN недостаточен.

- [slices sorting](https://pkg.go.dev/slices#SortFunc)

## Проверь себя

1. **Stable sort задаёт полный deterministic order при равных keys?**

   <details>
   <summary>Ответ</summary>

   Сохраняет входной порядок; независимость от него требует tie-breaker.

   </details>

2. **Почему comparator через subtraction опасен?**

   <details>
   <summary>Ответ</summary>

   Переполнение нарушает знак и транзитивность порядка.

   </details>
