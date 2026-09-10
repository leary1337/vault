---
title: Map в Go
description: Семантика map и современная Swiss Table implementation Go 1.27.
tags:
  - go
  - data-structures
  - runtime
level:
  - middle
  - senior
updated: 2026-09-10
created: 2024-07-30
---

# Map в Go

## Семантика

`map[K]V` — неупорядоченная коллекция key/value. Key type должен быть comparable. Map value ведёт себя как reference-like descriptor: assignment или передача в функцию не копирует все entries.

## Создание

```go
var nilMap map[string]int
ready := make(map[string]int)
withHint := make(map[string]int, 1_000)
literal := map[string]int{"ok": 1}
```

Size hint помогает заранее подобрать storage, но не задаёт capacity-контракт и не ограничивает число entries.

## Nil map

Из nil map можно читать, `len`, `range`, `delete` и `clear` безопасны. Assignment в nil map вызывает panic.

```go
fmt.Println(nilMap["missing"]) // 0
nilMap["key"] = 1             // panic
```

## Чтение и запись

```go
value := m[key]       // zero value, если key отсутствует
value, ok := m[key]   // ok различает missing и stored zero value
m[key] = value
```

Map index expression не addressable: взять `&m[key]` нельзя. Implementation может перемещать entries при росте. Для in-place mutation храните pointer value или read-modify-write struct value:

```go
item := m[key]
item.Count++
m[key] = item
```

## `delete` и `clear`

`delete(m, key)` ничего не делает для отсутствующего key и nil map. `clear(m)` удаляет все entries; дальнейшая реализация освобождения/reuse storage не является гарантией языка.

## Iteration

Порядок `range` не определён и может отличаться между iterations. Если entry ещё не достигнут и удалён, он не будет выдан. Entry, добавленный во время iteration, может быть выдан или пропущен. Для стабильного порядка соберите keys и отсортируйте их.

## Comparable keys

Booleans, numbers, strings, pointers, channels, interfaces, arrays и structs могут быть keys, если полностью comparable. Slices, maps и functions — нет. Key interface type допускается, но insertion/comparison паникует, если dynamic key type non-comparable.

Для floating-point keys учитывайте `NaN != NaN`: такой key нельзя надёжно найти тем же NaN value. Для domain key часто безопаснее struct из нормализованных integer/string fields.

## Concurrency

Несинхронизированные concurrent reads безопасны только когда ни одна goroutine не пишет. Concurrent read/write или write/write — data race; runtime иногда дополнительно завершает программу диагностикой, но это не замена synchronization.

Варианты:

- один owner goroutine;
- обычная map под `sync.Mutex`/`RWMutex`;
- `sync.Map` для его специализированных workload patterns.

## Что гарантирует язык

- Key uniqueness определяется `==`.
- Missing read возвращает zero value; comma-ok сообщает присутствие.
- Iteration order не определён.
- Адрес map element получить нельзя.
- Внутреннее hash layout, growth policy и probe sequence не являются language contract.

## Современная реализация

> Деталь реализации Go 1.27, не гарантия языка.

Начиная с Go 1.24 builtin map реализована на основе Swiss Tables. Старые объяснения через `hmap`, primary buckets, overflow buckets, `B`, `oldbuckets` и evacuation описывают legacy implementation и не должны использоваться для объяснения current performance.

### Swiss Tables

Storage организован в groups со slots для key/value и compact control metadata. Для занятого slot metadata содержит часть hash; специальные значения обозначают empty/deleted state. Lookup сначала сравнивает metadata сразу для группы кандидатов, а затем проверяет полные keys только в совпавших slots. Это уменьшает число дорогих key comparisons и улучшает locality.

### Hash split, directory и tables

Hash концептуально разделён:

- H1 направляет probing и, для больших maps, выбирает table через directory;
- H2 хранится в control metadata и служит быстрым фильтром внутри group.

Одна map может содержать несколько independent tables. Небольшие maps имеют special-case representation, чтобы не платить за полную directory structure.

### Probing

Lookup начинает с group, выбранной по hash, и следует probe sequence при collisions. Empty metadata завершает безуспешный search; deleted slots не могут всегда остановить search, потому что нужный key мог быть размещён дальше по probe sequence.

### Growth и table splitting

Когда table становится слишком заполненной, implementation rehash-ит её. Небольшая table может вырасти; крупная — split на две, после чего directory направляет разные hash prefixes в соответствующие tables. Такой incremental directory growth ограничивает объём работы отдельного grow по сравнению с обязательным перемещением всей map сразу.

Точные group sizes, load thresholds и максимальный размер table — изменяемые constants. Они полезны при чтении runtime source, но не должны зашиваться в прикладную логику или ответы о гарантиях языка.

## Performance

Средняя сложность lookup/insert обычно близка к O(1), но спецификация не обещает big-O, число probes или защиту от каждого adversarial workload. Реальная стоимость зависит от hashing, размера key/value, collision pattern, cache locality, роста и GC pressure.

Практически:

- используйте size hint, если размер действительно известен;
- избегайте дорогих composite keys на hot path без измерений;
- хранение больших pointer-rich values увеличивает GC scan work;
- benchmark должен отражать distribution keys, hit/miss ratio и mutation rate.

## Типичные ошибки

- Запись в nil map.
- Проверка присутствия через сравнение value с zero value.
- Ожидание стабильного order.
- Concurrent access без synchronization.
- Попытка изменить поле struct прямо через `m[key].Field`.
- Перенос старой `hmap`-модели на current runtime.

## Вопросы для самопроверки

1. Зачем нужен comma-ok при zero value?
2. Почему map element не addressable?
3. Что проверяет H2 metadata до сравнения key?
4. Почему deleted slot не всегда завершает lookup?
5. Какие части страницы являются specification, а какие implementation detail?

## Источники

- [Go specification: Map types](https://go.dev/ref/spec#Map_types)
- [Go blog: Faster Go maps with Swiss Tables](https://go.dev/blog/swisstable)
- [Go 1.24 Release Notes: map implementation](https://go.dev/doc/go1.24#runtime)
- [Current runtime map source](https://go.dev/src/internal/runtime/maps/map.go)
