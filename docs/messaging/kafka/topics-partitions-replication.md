---
title: Topics, partitions и replication
description: Ordering, offsets, ISR, retention и compaction.
tags: [messaging, kafka, replication]
updated: 2026-09-10
---

# Topics, partitions и replication

Topic — логическое имя stream, partition — физическая ordered log. Record получает monotonically increasing offset после append. Kafka не гарантирует глобальный порядок между partitions.

## Replicas и ISR

Replication factor задаёт число replicas partition. Одна replica — leader, остальные followers. In-Sync Replica (ISR) — follower, который удовлетворяет критериям синхронности с leader; ISR меняется во времени.

Leader принимает writes. При `acks=all` producer ждёт подтверждения всех текущих ISR, а не всех brokers и не обязательно всех назначенных replicas. `min.insync.replicas` задаёт минимальный размер ISR для успешной записи с `acks=all`; типичная защищённая комбинация RF=3, min ISR=2, acks=all выдерживает потерю одного replica для writes, но конкретный RPO также зависит от leader election и durability.

`unclean.leader.election.enable=true` может восстановить availability, выбрав out-of-sync replica ценой потери acknowledged tail. Default безопаснее, но оставляет partition unavailable, пока не вернётся подходящая ISR.

## Log lifecycle

Partition хранится сегментами. Cleanup policy:

- `delete` удаляет старые segments по времени/размеру;
- `compact` сохраняет последнее значение для каждого key, но compaction asynchronous и не обещает одну физическую запись на key в каждый момент;
- обе политики можно сочетать.

Tombstone (`key` с null value) обозначает удаление при compaction и хранится достаточно долго, чтобы consumers успели его увидеть согласно configuration. Record без key плохо подходит compacted topic.

Retention — не delivery acknowledgement: медленный consumer может потерять ещё не прочитанные records, если они вышли за retention. Наблюдайте lag относительно времени/bytes и sizing storage.

## Partition key

Records одного entity направляют в одну partition по стабильному key, если нужен per-entity order. Добавление partitions меняет modulo/hash mapping стандартного partitioner, поэтому существующий key может пойти в новую partition и нарушить порядок относительно старой history. Планируйте partition count заранее или используйте routing/versioning strategy.

## Источники

- [Kafka replication design](https://kafka.apache.org/43/design/replication/)
- [Topic configurations](https://kafka.apache.org/43/configuration/topic-configs/)
