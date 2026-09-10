---
title: Часы и порядок событий
description: Wall/monotonic clocks, Lamport clocks, vectors и fencing.
tags: [distributed-systems, time]
updated: 2026-09-10
---

# Часы и порядок событий

В распределённой системе нет бесплатно доступного точного глобального времени. Network delay непредсказуем, wall clock корректируется NTP/operator, process pauses; timestamp не является автоматическим доказательством причинности.

## Physical clocks

Wall clock нужен для календарного времени, TTL и audit, но может прыгнуть назад/вперёд. Monotonic clock измеряет elapsed duration внутри процесса и не зависит от wall-clock adjustment; используйте его для timeouts. После restart monotonic origin теряется.

Clock synchronization даёт error bound, а не идеальную синхронность. Lease safety должна учитывать maximum drift/uncertainty; если bound нарушен, старый holder может считать lease действующей.

## Logical order

Lamport clock присваивает counter так, что `a happens-before b ⇒ L(a) < L(b)`, но обратное неверно: числа не доказывают причинность. Для total tie-break добавляют node ID, однако этот порядок искусственный.

Vector clock/version vector может отличить causal order от concurrent versions, но metadata растёт с участниками и conflict resolution остаётся прикладной задачей. Hybrid Logical Clock сочетает приблизительное physical time с logical component и удобно сортирует события, не превращаясь в perfect global clock.

## Практика

- Ordering Kafka гарантирован внутри partition, не по producer wall timestamp.
- Database commit order и application event time различаются.
- Для idempotency используйте stable IDs/versions, не «timestamp почти уникален».
- Для lock holder side effects применяйте monotonically increasing fencing token, который downstream отвергает, если token устарел.
- В event schema храните event time, ingestion time и source sequence отдельно, если они нужны.

## Источники

- [Lamport: Time, Clocks, and the Ordering of Events](https://lamport.azurewebsites.net/pubs/time-clocks.pdf)
- [Hybrid Logical Clocks](https://cse.buffalo.edu/tech-reports/2014-04.pdf)
