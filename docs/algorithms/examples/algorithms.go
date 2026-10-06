package examples

import (
	"cmp"
	"container/heap"
	"container/list"
	"context"
	"errors"
	"slices"
	"sort"

	"golang.org/x/sync/errgroup"
)

// example:dedupe
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

// example:intervals
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

// example:window
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

// example:boundary
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

// example:topk
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

// example:jobs
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

// example:grid
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

// example:dfs
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

// example:lru
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

// example:workers
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

// example:coins
func minCoins(coins []int, amount int) int {
	if amount < 0 {
		return -1
	}
	for _, coin := range coins {
		if coin <= 0 {
			return -1
		}
	}
	dp := make([]int, amount+1)
	for sum := 1; sum <= amount; sum++ {
		dp[sum] = -1
		for _, coin := range coins {
			if coin <= sum && dp[sum-coin] >= 0 {
				candidate := dp[sum-coin] + 1
				if dp[sum] < 0 || candidate < dp[sum] {
					dp[sum] = candidate
				}
			}
		}
	}
	return dp[amount]
}

// example:subsets
func subsets(a []int) [][]int {
	out := make([][]int, 0)
	path := make([]int, 0, len(a))
	var visit func(int)
	visit = func(index int) {
		if index == len(a) {
			snapshot := append([]int(nil), path...)
			out = append(out, snapshot)
			return
		}
		visit(index + 1)
		path = append(path, a[index])
		visit(index + 1)
		path = path[:len(path)-1]
	}
	visit(0)
	return out
}

// example:prefix
func countSum(a []int64, target int64) int64 {
	seen := map[int64]int64{0: 1}
	var sum, answer int64
	for _, value := range a {
		sum += value
		answer += seen[sum-target]
		seen[sum]++
	}
	return answer
}

// example:twosum
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

// example:sort
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
