---
title: CAP и PACELC
description: Правильная область CAP и latency-consistency trade-off.
tags: [distributed-systems, consistency, cap]
updated: 2026-09-10
---

# CAP и PACELC

CAP не означает «всегда выбери любые две буквы из трёх». Если сеть разделила узлы, система не может одновременно гарантировать linearizable consistency и availability для каждого запроса на обеих сторонах partition.

## Термины

- C — linearizable view единой копии, а не любое значение слова consistency.
- A — каждый запрос к non-failing node получает non-error response, хотя ответ может быть stale; это формальное свойство, не процент uptime.
- P — система продолжает удовлетворять выбранному контракту несмотря на потерю/задержку части сообщений.

Partition tolerance не обычная feature, которую production cluster может «не выбрать»: network partition возможен. Во время него CP-система отказывает/останавливает часть операций, чтобы не нарушить consistency; AP-система отвечает на обеих сторонах и затем должна разрешить divergence.

Система может выбирать по-разному для разных operations. Например, stale read остаётся available, а write определённого key блокируется без quorum. После partition recovery также важны merge rules и client retries.

## PACELC

PACELC добавляет normal case: если Partition (P), trade-off Availability/Consistency (A/C); Else (E), trade-off Latency/Consistency (L/C). Даже при исправной сети synchronous cross-region quorum улучшает consistency/durability, но добавляет latency; local response быстрее, но допускает lag.

CAP/PACELC — frame для вопросов, не таблица выбора базы. Зафиксируйте operations, consistency model, topology, latency SLO, failure domain, RPO/RTO и поведение клиента при timeout.

## Источники

- [Brewer: CAP twelve years later](https://www.infoq.com/articles/cap-twelve-years-later-how-the-rules-have-changed/)
- [Abadi: Consistency tradeoffs in modern distributed database design](https://www.cs.umd.edu/~abadi/papers/abadi-pacelc.pdf)
