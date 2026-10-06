---
title: Часы и порядок событий
description: Wall/monotonic clocks, Lamport clocks, vectors и fencing.
tags: [distributed-systems, time]
updated: 2026-10-06
---

# Часы и порядок событий

Календарные часы называют время, логические часы кодируют связь событий; ни те ни другие автоматически не дают бизнес-порядок.

В распределённой системе нет бесплатно доступного точного глобального времени. Network delay непредсказуем, wall clock корректируется NTP/operator, process pauses; timestamp не является автоматическим доказательством причинности.

## Физические часы

Wall clock нужен для календарного времени, TTL (время жизни записи) и audit, но может прыгнуть назад/вперёд. Monotonic clock измеряет elapsed duration внутри процесса и не зависит от wall-clock adjustment; используйте его для timeouts. После restart monotonic origin теряется.

Clock synchronization даёт error bound, а не идеальную синхронность. Lease (временное право владения) safety должна учитывать maximum drift/uncertainty; если bound нарушен, старый holder может считать lease действующей.

## Логический порядок

Lamport clock присваивает counter так, что `a happens-before b ⇒ L(a) < L(b)`, но обратное неверно: числа не доказывают причинность. Для total tie-break добавляют node ID, однако этот порядок искусственный.

Vector clock/version vector может отличить causal order от concurrent versions, но metadata растёт с участниками и conflict resolution остаётся прикладной задачей. Hybrid Logical Clock сочетает приблизительное physical time с logical component и удобно сортирует события, не превращаясь в perfect global clock.

## Практика

- Ordering Kafka гарантирован внутри partition (раздел журнала или данных; при network partition — разрыв связи), не по producer wall timestamp.
- Database commit (фиксация результата, который считается подтверждённым) order и application event time различаются.
- Для idempotency используйте stable IDs/versions, не «timestamp почти уникален».
- Для lock holder side effects применяйте monotonically increasing fencing (отклонение действий старого владельца самим ресурсом) token, который downstream отвергает, если token устарел.
- В event schema храните event time, ingestion time и source sequence отдельно, если они нужны.

## Источники

- [Lamport: Time, Clocks, and the Ordering of Events](https://lamport.azurewebsites.net/pubs/time-clocks.pdf)
- [Hybrid Logical Clocks](https://cse.buffalo.edu/tech-reports/2014-04.pdf)

## Механизм на примере

A отправляет событие с Lamport=5; B имеет counter=3, получает его и ставит `max(3,5)+1=6`. Следующее событие B получает 7. Если независимый C имеет 10, нельзя заключить, что он видел B: `L(a)<L(b)` не доказывает причинность в обратную сторону.

Vector примера: `[2,0]` и `[1,1]` несравнимы — один видел второе событие A, другой первое A и первое B; это конкурентные версии. Разрешение конфликта всё равно зависит от смысла: объединить множества можно, два изменения цены нельзя автоматически сложить.

Monotonic time полезен для длительности внутри процесса, но после сериализации timestamp через сеть его монотонная часть обычно не переносится. Срок lease на другой машине нельзя безопасно сравнить с произвольным локальным monotonic origin.

## Проверь себя

1. Доказывает ли больший Lamport причинность?
2. Почему timestamp нельзя использовать как lock generation?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, меньший counter необходим для happens-before, но недостаточен.
2. Часы могут расходиться и прыгать; нужен согласованно возрастающий token.

</details>
