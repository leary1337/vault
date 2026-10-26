---
title: Разобранные функции Go
updated: 2026-10-06T00:00:00.000Z
description: >-
  Функции с объяснением входа, результата, каждого механизма и условий
  применения.
tags:
  - algorithms
  - go
  - interviews
---

# Разобранные функции Go

Здесь функции демонстрируют конкретный контракт, включая изменение входных данных и граничные случаи. Смотрите не только код, но и причину каждого движения границы.

Функции собраны в [отдельном учебном Go-модуле](examples.md) с тестами. Версии Go 1.27.1 и зависимости закреплены в `go.mod`. Здесь показаны объявления функций, а не самостоятельные программы с `main`. Все необходимые импорты есть в модуле: `container/heap`, `container/list`, `context`, `errors`, `sort`, `golang.org/x/sync/errgroup`; отдельной функции нужны только используемые ею пакеты.

## Удаление дублей на месте

Массив уже отсортирован. Индекс `r` читает очередное число, `w` отмечает следующее место ответа. Если число отличается от последнего сохранённого, код записывает его в `a[w]`. Для `[1,1,2]` получается `[1,2]`; остальные позиции больше не относятся к ответу. Один проход — `O(n)`, дополнительная память `O(1)`.

```go
func dedupeSorted(a []int) []int {
	if len(a) == 0 {
		return a
	}
	w := 1
	for r := 1; r < len(a); r++ {
		if a[r] != a[w-1] {
			a[w] = a[r]
			w++
		}
	}
	return a[:w]
}
```

Пустой вход и один элемент возвращаются без изменений. На неотсортированных данных соседнее сравнение не удалит все повторы. Результат использует тот же массив: изменение видно другим слайсам.

## Слияние интервалов

Вход содержит закрытые интервалы. Сортировка ставит их по началу, поэтому очередной интервал сравнивается только с последней группой результата. `[1,3],[2,4]` превращаются в `[1,4]`: начало второго уже внутри первого, конец расширяется. Время `O(n log n)`, память результата до `O(n)` плюс память сортировки.

```go
type Interval struct {
	Start int
	End   int
}

func mergeIntervals(in []Interval) []Interval {
	if len(in) == 0 {
		return nil
	}
	sort.Slice(in, func(i, j int) bool {
		if in[i].Start == in[j].Start {
			return in[i].End < in[j].End
		}
		return in[i].Start < in[j].Start
	})
	out := make([]Interval, 0, len(in))
	for _, cur := range in {
		if len(out) == 0 || cur.Start > out[len(out)-1].End {
			out = append(out, cur)
		} else if cur.End > out[len(out)-1].End {
			out[len(out)-1].End = cur.End
		}
	}
	return out
}
```

Предполагается `Start<=End`; функция не проверяет неверные границы. Закрытые `[1,2]` и `[2,3]` объединяются, потому что имеют общую точку. Для полуоткрытых границ условие изменится. Сортировка меняет вход.

## Строка без повторов

Нужна длина самого длинного участка без повторов кодовых точек Unicode. Таблица `last` хранит последнюю позицию символа; повтор внутри окна переносит `left` за него. Для `abba` ответ 2. Переменная `pos` считает кодовые точки, не байты. Время `O(n)`, память `O(k)`, где k — число разных кодовых точек.

```go
func longestUnique(s string) int {
	last := make(map[rune]int)
	left, best, pos := 0, 0, 0
	for _, r := range s {
		if p, ok := last[r]; ok && p >= left {
			left = p + 1
		}
		last[r] = pos
		if n := pos - left + 1; n > best {
			best = n
		}
		pos++
	}
	return best
}
```

Неверные байты UTF-8 при обходе превращаются в `RuneError`. Видимый символ может состоять из нескольких кодовых точек, например буквы и знака ударения; для такой единицы нужна сегментация Unicode.

## Двоичный поиск границы

Ищем первый индекс с `a[i]>=target` в отсортированном массиве. Правая граница `hi` исключена. Подходящая середина переносит `hi`, неподходящая — `lo` за середину. Для `[1,3,3,7]` и 3 результат 1; для 9 — 4, позиция после конца. Время `O(log n)`, память `O(1)`.

```go
func lowerBound(a []int, target int) int {
	lo, hi := 0, len(a)
	for lo < hi {
		mid := lo + (hi-lo)/2
		if a[mid] >= target {
			hi = mid
		} else {
			lo = mid + 1
		}
	}
	return lo
}
```

Пустой вход даёт 0. Возвращённое число — позиция вставки, не обещание найденного значения: сначала проверьте `i<len(a)`, затем `a[i]==target`.

## K самых частых чисел

Сначала считаем частоты, затем держим не более K кандидатов в минимальной куче. Её вершина — самый редкий из выбранных, его удаляют при переполнении. Для `[1,1,1,2,2,3]` и K=2 ответ содержит 1 и 2. Время `O(n+m log k)` при k>0, где m — число разных значений; память `O(m+k)`.

```go
type freqItem struct {
	value int
	count int
}

type minFreq []freqItem

func (h minFreq) Len() int {
	return len(h)
}
func (h minFreq) Less(i, j int) bool {
	return h[i].count < h[j].count
}
func (h minFreq) Swap(i, j int) {
	h[i], h[j] = h[j], h[i]
}
func (h *minFreq) Push(x any) {
	*h = append(*h, x.(freqItem))
}
func (h *minFreq) Pop() any {
	old := *h
	x := old[len(old)-1]
	*h = old[:len(old)-1]
	return x
}
func topKFrequent(a []int, k int) []int {
	if k <= 0 {
		return nil
	}
	f := make(map[int]int)
	for _, x := range a {
		f[x]++
	}
	h := &minFreq{}
	heap.Init(h)
	for v, n := range f {
		heap.Push(h, freqItem{v, n})
		if h.Len() > k {
			heap.Pop(h)
		}
	}
	out := make([]int, h.Len())
	for i := len(out) - 1; i >= 0; i-- {
		out[i] = heap.Pop(h).(freqItem).value
	}
	return out
}
```

При K<=0 ответ пустой; при K больше числа разных значений возвращаются все. Равные частоты не имеют фиксированного порядка из-за обхода map и отсутствия дополнительного сравнения.

## Очередь приоритетов

Задача с меньшим числом `Priority` извлекается раньше. Поле `index` запоминает положение элемента, чтобы `Update` вызвал `heap.Fix` и восстановил порядок после изменения. Добавление, извлечение и изменение стоят `O(log n)`, просмотр вершины `O(1)`, память `O(n)`.

```go
type Job struct {
	Name     string
	Priority int
	index    int
}
type JobHeap []*Job

func (h JobHeap) Len() int {
	return len(h)
}
func (h JobHeap) Less(i, j int) bool {
	return h[i].Priority < h[j].Priority
}
func (h JobHeap) Swap(i, j int) {
	h[i], h[j] = h[j], h[i]
	h[i].index = i
	h[j].index = j
}
func (h *JobHeap) Push(x any) {
	j := x.(*Job)
	j.index = len(*h)
	*h = append(*h, j)
}
func (h *JobHeap) Pop() any {
	old := *h
	n := len(old)
	j := old[n-1]
	old[n-1] = nil
	j.index = -1
	*h = old[:n-1]
	return j
}
func (h *JobHeap) Update(j *Job, priority int) {
	j.Priority = priority
	heap.Fix(h, j.index)
}
```

Для работы вызывайте функции пакета `heap`, а не только метод `Pop` структуры. Нельзя обновлять удалённый элемент: его индекс уже -1. `Swap` обновляет индексы, удаление обнуляет ссылку, конкурентное использование требует синхронизации.

## Кратчайший путь по сетке

Нули — свободные клетки, остальные значения — препятствия. Ищем путь из верхнего левого в нижний правый угол в четырёх направлениях. BFS кладёт соседей в очередь и сразу отмечает расстояние, поэтому первый приход кратчайший по числу переходов. Время и память `O(rows×cols)`.

```go
func shortestGrid(g [][]int) int {
	if len(g) == 0 || len(g[0]) == 0 || g[0][0] != 0 {
		return -1
	}
	rows, cols := len(g), len(g[0])
	dist := make([][]int, rows)
	for i := range dist {
		dist[i] = make([]int, cols)
		for j := range dist[i] {
			dist[i][j] = -1
		}
	}
	type cell struct {
		i int
		j int
	}
	q := []cell{{0, 0}}
	dist[0][0] = 0
	dirs := [][2]int{{1, 0}, {-1, 0}, {0, 1}, {0, -1}}
	for head := 0; head < len(q); head++ {
		v := q[head]
		if v.i == rows-1 && v.j == cols-1 {
			return dist[v.i][v.j]
		}
		for _, d := range dirs {
			ni, nj := v.i+d[0], v.j+d[1]
			if ni >= 0 && ni < rows && nj >= 0 && nj < cols &&
				g[ni][nj] == 0 && dist[ni][nj] < 0 {
				dist[ni][nj] = dist[v.i][v.j] + 1
				q = append(q, cell{ni, nj})
			}
		}
	}
	return -1
}
```

Нужна прямоугольная сетка: строки разной длины не поддерживаются. Одна свободная клетка даёт 0 переходов. Для разной цены переходов BFS не минимизирует стоимость; нужен другой алгоритм.

## Обход графа без рекурсии

Таблица `seen` отмечает достигнутые вершины, явный стек хранит ожидающие обработки. Вершина отмечается при добавлении, поэтому циклы не запускают бесконечный обход. Результат — множество достижимых, не упорядоченный маршрут. Время `O(V+E)` для доступной части, память `O(V)`.

```go
func reachable(graph map[int][]int, start int) map[int]bool {
	seen := map[int]bool{start: true}
	stack := []int{start}
	for len(stack) > 0 {
		n := len(stack) - 1
		v := stack[n]
		stack = stack[:n]
		for _, to := range graph[v] {
			if !seen[to] {
				seen[to] = true
				stack = append(stack, to)
			}
		}
	}
	return seen
}
```

Начальная вершина считается достигнутой даже без списка соседей. Порядок зависит от списков; направленные рёбра не становятся двусторонними автоматически. Явный стек убирает рекурсивные вызовы, но всё равно занимает память.

## Кэш с вытеснением по давности

LRU сохраняет недавно использованные записи, удаляя самую давно неиспользуемую. Map быстро находит узел списка, список быстро переносит его в начало. При вместимости 2 после записи A,B и чтения A запись C удалит B. Поиск и изменение имеют обычную `O(1)` стоимость; память `O(capacity)`.

```go
type entry struct {
	key   string
	value any
}
type LRU struct {
	cap   int
	ll    *list.List
	byKey map[string]*list.Element
}

func NewLRU(capacity int) *LRU {
	return &LRU{capacity, list.New(), make(map[string]*list.Element)}
}
func (c *LRU) Get(k string) (any, bool) {
	e, ok := c.byKey[k]
	if !ok {
		return nil, false
	}
	c.ll.MoveToFront(e)
	return e.Value.(entry).value, true
}
func (c *LRU) Put(k string, v any) {
	if c.cap <= 0 {
		return
	}
	if e := c.byKey[k]; e != nil {
		e.Value = entry{k, v}
		c.ll.MoveToFront(e)
		return
	}
	e := c.ll.PushFront(entry{k, v})
	c.byKey[k] = e
	if c.ll.Len() > c.cap {
		old := c.ll.Back()
		delete(c.byKey, old.Value.(entry).key)
		c.ll.Remove(old)
	}
}
```

Нулевая или отрицательная вместимость не сохраняет данные. Bool отличает отсутствие от сохранённого nil. Ограничивается число записей, не байты; TTL и конкурентной безопасности у реализации нет.

## Ограниченный набор исполнителей

Функция запускает фиксированное число горутин, читающих задачи из канала. Каждая задача получает контекст; первая ошибка отменяет общий контекст, `Wait` ждёт окончания участников. Очередь и число исполнителей должны быть ограничены снаружи. Цена зависит прежде всего от выполнения задач, не только от их числа.

```go
func runWorkers(ctx context.Context, workers int, jobs <-chan func(context.Context) error) error {
	if workers <= 0 {
		return errors.New("workers must be positive")
	}
	g, ctx := errgroup.WithContext(ctx)
	for i := 0; i < workers; i++ {
		g.Go(func() error {
			for {
				select {
				case <-ctx.Done():
					return ctx.Err()
				case job, ok := <-jobs:
					if !ok {
						return nil
					}
					if err := job(ctx); err != nil {
						return err
					}
				}
			}
		})
	}
	return g.Wait()
}
```

Отправитель обязан завершить выдачу и закрыть канал или реагировать на отмену. Задача тоже должна проверять контекст: он не прерывает код принудительно. Nil-задача недопустима. Если нужно собрать все ошибки, требуется другая политика, а не отмена на первой.

## Как проверять пример

Для `[1,3,3,7]` вызовы `lowerBound` с целями 0, 3 и 9 дают позиции 0, 1 и 4. Последняя означает вставку после конца, не найденный индекс. Дополнительно проверьте пустой вход и один элемент.

`longestUnique("abba")` даёт 2; `longestUnique("😀a😀")` тоже 2, поскольку считаются кодовые точки, не байты. `shortestGrid` считает переходы между свободными клетками: сетка из одной свободной клетки даёт 0.

Набор исполнителей использует `golang.org/x/sync/errgroup`. Отправитель и сами задачи реагируют на отмену. Если в `select` одновременно готовы задача и отмена, может быть выбрана задача: это не гарантия, что после сигнала ни одна новая работа не начнётся. Контекст сообщает намерение отменить, не прерывает произвольный код.

Исполняемые companion-файлы с точными объявлениями и тестами находятся в [examples](examples.md). Они показывают компиляцию и проверки конкретных случаев, а не универсальное доказательство любого входа.

## Проверь себя

1. **Что проверить помимо обычного успешного входа?**
2. **Почему компиляция не доказывает алгоритм?**
