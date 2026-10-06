package examples

import (
	"container/heap"
	"context"
	"errors"
	"reflect"
	"slices"
	"sync/atomic"
	"testing"
	"time"
)

func TestDedupe(t *testing.T) {
	for _, tc := range []struct{ in, want []int }{
		{nil, nil}, {[]int{1}, []int{1}}, {[]int{1, 1, 2, 2, 3}, []int{1, 2, 3}},
	} {
		if got := dedupeSorted(slices.Clone(tc.in)); !reflect.DeepEqual(got, tc.want) {
			t.Fatalf("dedupe(%v)=%v; want %v", tc.in, got, tc.want)
		}
	}
}
func TestIntervals(t *testing.T) {
	got := mergeIntervals([]Interval{{6, 8}, {2, 4}, {1, 3}, {4, 4}})
	if !reflect.DeepEqual(got, []Interval{{1, 4}, {6, 8}}) {
		t.Fatal(got)
	}
	if mergeIntervals(nil) != nil {
		t.Fatal("empty")
	}
}
func TestUniqueRunes(t *testing.T) {
	for _, tc := range []struct {
		s    string
		want int
	}{
		{"", 0}, {"abba", 2}, {"😀a😀", 2}, {"abc", 3},
	} {
		if got := longestUnique(tc.s); got != tc.want {
			t.Fatalf("%q: got %d want %d", tc.s, got, tc.want)
		}
	}
}
func TestLowerBound(t *testing.T) {
	for n := 0; n < 40; n++ {
		a := make([]int, n)
		for i := range a {
			a[i] = i / 2
		}
		for target := -1; target <= 25; target++ {
			want := 0
			for want < len(a) && a[want] < target {
				want++
			}
			if got := lowerBound(a, target); got != want {
				t.Fatalf("%v target %d: %d != %d", a, target, got, want)
			}
		}
	}
}
func TestTopK(t *testing.T) {
	got := topKFrequent([]int{1, 1, 1, 2, 2, 3}, 2)
	slices.Sort(got)
	if !reflect.DeepEqual(got, []int{1, 2}) {
		t.Fatal(got)
	}
	if len(topKFrequent([]int{1, 2}, 10)) != 2 || len(topKFrequent(nil, 0)) != 0 {
		t.Fatal("bounds")
	}
}
func TestHeapUpdate(t *testing.T) {
	h := &JobHeap{}
	a := &Job{Name: "a", Priority: 10}
	b := &Job{Name: "b", Priority: 20}
	heap.Push(h, a)
	heap.Push(h, b)
	h.Update(b, 1)
	if heap.Pop(h).(*Job) != b || b.index != -1 {
		t.Fatal("update/removal")
	}
	if heap.Pop(h).(*Job) != a {
		t.Fatal("remaining")
	}
}
func TestGrid(t *testing.T) {
	for _, tc := range []struct {
		g    [][]int
		want int
	}{
		{nil, -1}, {[][]int{{0}}, 0}, {[][]int{{1}}, -1},
		{[][]int{{0, 0}, {1, 0}}, 2}, {[][]int{{0, 1}, {1, 0}}, -1},
	} {
		if got := shortestGrid(tc.g); got != tc.want {
			t.Fatalf("grid %v: %d != %d", tc.g, got, tc.want)
		}
	}
}
func TestDFS(t *testing.T) {
	got := reachable(map[int][]int{1: {2}, 2: {1, 3}, 4: {5}}, 1)
	if !reflect.DeepEqual(got, map[int]bool{1: true, 2: true, 3: true}) {
		t.Fatal(got)
	}
}
func TestLRU(t *testing.T) {
	c := NewLRU(2)
	c.Put("a", nil)
	c.Put("b", 2)
	if v, ok := c.Get("a"); !ok || v != nil {
		t.Fatal("nil value")
	}
	c.Put("c", 3)
	if _, ok := c.Get("b"); ok {
		t.Fatal("b should be evicted")
	}
	c.Put("a", 4)
	if v, ok := c.Get("a"); !ok || v != 4 {
		t.Fatal("update")
	}
	zero := NewLRU(0)
	zero.Put("x", 1)
	if _, ok := zero.Get("x"); ok {
		t.Fatal("zero capacity")
	}
}
func TestWorkersComplete(t *testing.T) {
	jobs := make(chan func(context.Context) error, 30)
	var count atomic.Int32
	for i := 0; i < 30; i++ {
		jobs <- func(context.Context) error {
			count.Add(1)
			return nil
		}
	}
	close(jobs)
	if err := runWorkers(context.Background(), 3, jobs); err != nil || count.Load() != 30 {
		t.Fatal(err, count.Load())
	}
}
func TestWorkersCancellation(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	jobs := make(chan func(context.Context) error)
	done := make(chan error, 1)
	go func() { done <- runWorkers(ctx, 2, jobs) }()
	cancel()
	select {
	case err := <-done:
		if !errors.Is(err, context.Canceled) {
			t.Fatal(err)
		}
	case <-time.After(2 * time.Second):
		t.Fatal("workers blocked on open empty channel after cancellation")
	}
}
func TestWorkersErrors(t *testing.T) {
	sentinel := errors.New("job failed")
	jobs := make(chan func(context.Context) error, 1)
	jobs <- func(context.Context) error { return sentinel }
	close(jobs)
	if err := runWorkers(context.Background(), 1, jobs); !errors.Is(err, sentinel) {
		t.Fatal(err)
	}
	if err := runWorkers(context.Background(), 0, jobs); err == nil {
		t.Fatal("invalid workers")
	}
}
func TestCoins(t *testing.T) {
	for _, tc := range []struct {
		coins        []int
		amount, want int
	}{
		{[]int{1, 3, 4}, 6, 2}, {[]int{2}, 3, -1}, {nil, 0, 0},
		{[]int{0}, 3, -1}, {[]int{1}, -1, -1},
	} {
		if got := minCoins(tc.coins, tc.amount); got != tc.want {
			t.Fatalf("%v %d: %d != %d", tc.coins, tc.amount, got, tc.want)
		}
	}
}
func TestSubsetsSnapshots(t *testing.T) {
	got := subsets([]int{1, 2})
	if !reflect.DeepEqual(got, [][]int{nil, {2}, {1}, {1, 2}}) {
		t.Fatal(got)
	}
	got[3][0] = 99
	if got[2][0] != 1 {
		t.Fatal("answers alias")
	}
	if len(subsets(nil)) != 1 {
		t.Fatal("empty set has one subset")
	}
}
func TestPrefixCount(t *testing.T) {
	for n := 0; n <= 7; n++ {
		a := make([]int64, n)
		for i := range a {
			a[i] = int64(i%3) - 1
		}
		for target := int64(-2); target <= 2; target++ {
			var want int64
			for left := range a {
				var sum int64
				for right := left; right < len(a); right++ {
					sum += a[right]
					if sum == target {
						want++
					}
				}
			}
			if got := countSum(a, target); got != want {
				t.Fatalf("%v target%d: %d != %d", a, target, got, want)
			}
		}
	}
}
func TestTwoSum(t *testing.T) {
	i, j, ok := twoSum([]int{3, 3}, 6)
	if !ok || i != 0 || j != 1 {
		t.Fatal(i, j, ok)
	}
	if _, _, ok := twoSum([]int{3}, 6); ok {
		t.Fatal("used same index")
	}
}
func TestSortingTies(t *testing.T) {
	a := []PersonScore{{3, 2}, {1, 1}, {2, 2}}
	sortScores(a)
	if !reflect.DeepEqual(a, []PersonScore{{1, 1}, {2, 2}, {3, 2}}) {
		t.Fatal(a)
	}
}
