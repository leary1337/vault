---
title: Модели согласованности
description: Linearizability, sequential, causal и client-centric guarantees.
tags: [distributed-systems, consistency]
updated: 2026-09-10
---

# Модели согласованности

Consistency model ограничивает результаты concurrent operations, которые разрешено наблюдать. Это контракт API/storage, а не синоним «реплики когда-нибудь совпадут».

## Strong models

- Linearizability: каждая operation выглядит мгновенной между invocation и response и уважает real-time order. После завершившейся записи более позднее чтение не может вернуть старое значение.
- Sequential consistency: существует единый порядок operations, согласованный с program order каждого client, но не обязан уважать real time между clients.
- Serializability: transaction outcome эквивалентен последовательному выполнению transactions. Без strictness она не обязательно linearizable относительно real time.
- Strict serializability объединяет serializability с real-time ordering и является transactional аналогом linearizability.

Не смешивайте isolation level внутри одной database с consistency replicated service: это связанные, но разные границы.

## Weaker и session guarantees

- Causal consistency сохраняет cause-before-effect; concurrent независимые writes могут наблюдаться в разном порядке.
- Eventual consistency обещает convergence при отсутствии новых updates, но сама по себе не задаёт conflict resolution, maximum staleness или session behavior.
- Read-your-writes позволяет client видеть собственные завершённые writes.
- Monotonic reads не возвращает одной session всё более старые версии.
- Monotonic writes сохраняет порядок writes session.
- Bounded staleness ограничивает отставание временем или версиями.

## Как выбирать

Сначала задайте invariant. Уникальная выдача денег/lease часто требует linearizable compare-and-set или serializable transaction. Feed и analytics могут допускать stale reads. Один сервис может давать разные guarantees: linearizable metadata и eventual cache.

Тестируйте model при реальных faults и concurrency. «Запись ушла на три replicas» ещё не доказывает linearizability: важны quorum intersection, leader fencing, retry semantics и read path.

## Источники

- [Herlihy and Wing: Linearizability](https://cs.brown.edu/~mph/HerlihyW90/p463-herlihy.pdf)
- [Jepsen consistency models](https://jepsen.io/consistency/models)
