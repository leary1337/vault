---
title: Go examples
description: Разобранные templates алгоритмов на Go.
tags: [algorithms, go, interviews]
updated: 2026-09-10
---

# Go examples

Snippets независимы: добавьте нужные imports и tests в отдельный package. На рабочей машине нет Go toolchain, поэтому код прошёл ручную проверку, но не compilation test.

## Deduplicate sorted slice in-place

**Problem:** оставить по одному экземпляру каждого числа. **Approach:** write pointer хранит следующий slot результата; sorted order делает duplicates соседними. **Time:** `O(n)`. **Space:** `O(1)` auxiliary.

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

**Edge cases:** empty/single input, all equal; функция меняет backing array и не подходит unsorted data.

## Merge intervals

**Problem:** объединить пересекающиеся closed intervals. **Approach:** sort по start/end, сравнивать с последним result. **Time:** `O(n log n)`. **Space:** `O(n)` result плюс sort stack.

```go
type Interval struct{ Start, End int }

func mergeIntervals(in []Interval) []Interval {
	if len(in) == 0 { return nil }
	sort.Slice(in, func(i, j int) bool {
		if in[i].Start == in[j].Start { return in[i].End < in[j].End }
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

**Edge cases:** invalid `Start > End`; touching `[1,2]`/`[2,3]` merge для closed, но не обязательно для half-open; input сортируется in-place.

## Sliding window

**Problem:** длина longest substring без повторяющихся Unicode code points. **Approach:** хранить последнюю rune-position и сдвигать left только вперёд. **Time:** `O(n)` runes. **Space:** `O(k)` distinct runes.

```go
func longestUnique(s string) int {
	last := make(map[rune]int)
	left, best, pos := 0, 0, 0
	for _, r := range s {
		if p, ok := last[r]; ok && p >= left {
			left = p + 1
		}
		last[r] = pos
		if n := pos - left + 1; n > best { best = n }
		pos++
	}
	return best
}
```

**Edge cases:** invalid UTF-8 превращается в `RuneError` values; grapheme clusters могут состоять из нескольких runes и требуют Unicode segmentation library.

## Binary search boundary

**Problem:** первый index с `a[i] >= target`. **Approach:** half-open invariant `[lo, hi)`, answer может быть `len(a)`. **Time:** `O(log n)`. **Space:** `O(1)`.

```go
func lowerBound(a []int, target int) int {
	lo, hi := 0, len(a)
	for lo < hi {
		mid := lo + (hi-lo)/2
		if a[mid] >= target { hi = mid } else { lo = mid + 1 }
	}
	return lo
}
```

**Edge cases:** empty input, target outside range, duplicates; slice обязан быть sorted.

## Top K frequent

**Problem:** вернуть до K наиболее частых чисел. **Approach:** frequencies + min-heap размера K. **Time:** `O(n + m log k)`, m distinct. **Space:** `O(m+k)`.

```go
type freqItem struct{ value, count int }
type minFreq []freqItem
func (h minFreq) Len() int { return len(h) }
func (h minFreq) Less(i, j int) bool { return h[i].count < h[j].count }
func (h minFreq) Swap(i, j int) { h[i], h[j] = h[j], h[i] }
func (h *minFreq) Push(x any) { *h = append(*h, x.(freqItem)) }
func (h *minFreq) Pop() any { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }

func topKFrequent(a []int, k int) []int {
	if k <= 0 { return nil }
	f := make(map[int]int)
	for _, x := range a { f[x]++ }
	h := &minFreq{}; heap.Init(h)
	for v, n := range f {
		heap.Push(h, freqItem{v, n})
		if h.Len() > k { heap.Pop(h) }
	}
	out := make([]int, h.Len())
	for i := len(out)-1; i >= 0; i-- { out[i] = heap.Pop(h).(freqItem).value }
	return out
}
```

**Edge cases:** k больше distinct count; ties имеют недетерминированный order из-за map — добавьте comparator/tie-breaker, если contract требует.

## Priority heap

**Problem:** scheduler извлекает job с наименьшим priority number. **Approach:** реализовать `heap.Interface`; update требует сохранённого index. **Time:** push/pop/update `O(log n)`, peek `O(1)`. **Space:** `O(n)`.

```go
type Job struct { Name string; Priority, index int }
type JobHeap []*Job
func (h JobHeap) Len() int { return len(h) }
func (h JobHeap) Less(i, j int) bool { return h[i].Priority < h[j].Priority }
func (h JobHeap) Swap(i, j int) { h[i], h[j] = h[j], h[i]; h[i].index=i; h[j].index=j }
func (h *JobHeap) Push(x any) { j:=x.(*Job); j.index=len(*h); *h=append(*h,j) }
func (h *JobHeap) Pop() any { old:=*h; n:=len(old); j:=old[n-1]; old[n-1]=nil; j.index=-1; *h=old[:n-1]; return j }
func (h *JobHeap) Update(j *Job, p int) { j.Priority=p; heap.Fix(h, j.index) }
```

**Edge cases:** не вызывайте update после removal; nil-out removed pointer, чтобы не удерживать memory; concurrency требует внешней синхронизации.

## BFS grid

**Problem:** shortest path из top-left в bottom-right по cells `0`, четыре направления. **Approach:** BFS и distance при enqueue. **Time:** `O(rows×cols)`. **Space:** `O(rows×cols)`.

```go
func shortestGrid(g [][]int) int {
	if len(g)==0 || len(g[0])==0 || g[0][0]!=0 { return -1 }
	r, c := len(g), len(g[0]); dist := make([][]int, r)
	for i := range dist { dist[i]=make([]int,c); for j:=range dist[i] { dist[i][j]=-1 } }
	type cell struct{ i,j int }; q:=[]cell{{0,0}}; dist[0][0]=0
	dirs:=[][2]int{{1,0},{-1,0},{0,1},{0,-1}}
	for head:=0; head<len(q); head++ {
		v:=q[head]; if v.i==r-1 && v.j==c-1 { return dist[v.i][v.j] }
		for _,d:=range dirs { ni,nj:=v.i+d[0],v.j+d[1]
			if ni>=0&&ni<r&&nj>=0&&nj<c&&g[ni][nj]==0&&dist[ni][nj]<0 { dist[ni][nj]=dist[v.i][v.j]+1; q=append(q,cell{ni,nj}) }
		}
	}
	return -1
}
```

**Edge cases:** ragged rows не поддержаны; start=end возвращает 0; weighted moves требуют Dijkstra, не BFS.

## Iterative DFS

**Problem:** вернуть reachable nodes adjacency-list graph. **Approach:** explicit stack избегает recursion overflow. **Time:** `O(V+E)` reachable. **Space:** `O(V)`.

```go
func reachable(graph map[int][]int, start int) map[int]bool {
	seen := map[int]bool{start:true}
	stack := []int{start}
	for len(stack)>0 {
		n:=len(stack)-1; v:=stack[n]; stack=stack[:n]
		for _,to:=range graph[v] { if !seen[to] { seen[to]=true; stack=append(stack,to) } }
	}
	return seen
}
```

**Edge cases:** start без adjacency всё равно reachable; traversal order зависит от adjacency order; directed edges не добавляются автоматически в обе стороны.

## LRU cache

**Problem:** O(1) get/put с eviction least recently used. **Approach:** map key → doubly-linked-list element, front = recent. **Time:** `O(1)`. **Space:** `O(capacity)`.

```go
type entry struct{ key string; value any }
type LRU struct { cap int; ll *list.List; byKey map[string]*list.Element }
func NewLRU(capacity int) *LRU { return &LRU{capacity,list.New(),make(map[string]*list.Element)} }
func (c *LRU) Get(k string) (any,bool) { e,ok:=c.byKey[k]; if !ok{return nil,false}; c.ll.MoveToFront(e); return e.Value.(entry).value,true }
func (c *LRU) Put(k string, v any) {
	if c.cap<=0{return}
	if e:=c.byKey[k]; e!=nil { e.Value=entry{k,v}; c.ll.MoveToFront(e); return }
	e:=c.ll.PushFront(entry{k,v}); c.byKey[k]=e
	if c.ll.Len()>c.cap { old:=c.ll.Back(); delete(c.byKey,old.Value.(entry).key); c.ll.Remove(old) }
}
```

**Edge cases:** zero capacity; `nil` value отличать через bool; implementation не thread-safe и не имеет TTL/size-in-bytes.

## Worker pool

**Problem:** обработать jobs с bounded concurrency и cancellation. **Approach:** fixed workers читают channel, producer закрывает его. **Time:** `O(n)` work плюс job cost. **Space:** bounded channel + workers.

```go
func runWorkers(ctx context.Context, workers int, jobs <-chan func(context.Context) error) error {
	if workers <= 0 { return errors.New("workers must be positive") }
	g, ctx := errgroup.WithContext(ctx)
	for i:=0; i<workers; i++ {
		g.Go(func() error {
			for {
				select {
				case <-ctx.Done(): return ctx.Err()
				case job, ok := <-jobs:
					if !ok { return nil }
					if err := job(ctx); err != nil { return err }
				}
			}
		})
	}
	return g.Wait()
}
```

**Edge cases:** caller обязан закрыть/provide jobs; первая ошибка отменяет peers только если jobs уважают context; blocked producer тоже должен select по context; для «собрать все errors» нужна другая policy.
