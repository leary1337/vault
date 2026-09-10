# Content backlog

Статусы: `TODO`, `IN PROGRESS`, `DONE`. Приоритеты отражают риск неправильного применения материала, а не только объём темы.

| Topic | Priority | Status | Notes |
|---|---:|---|---|
| Batch 1 — migration foundation | P0 | DONE | 50 страниц перенесено, indexes пересобраны, legacy tree удалён после проверки |
| Go basics и strings/bytes/runes | P0 | DONE | Проверено для Go 1.27; performance claim и UTF-8 исправлены |
| Go slice и map | P0 | DONE | Map переписана под Swiss Tables current stable; growth отмечен implementation detail |
| Go interfaces, errors, panic/recover | P0 | DONE | Добавлены method sets, typed nil, boundaries и recovery scope |
| Go generics | P0 | DONE | Go 1.27: generic aliases и generic methods с version boundaries |
| Go memory model и concurrency | P0 | DONE | Добавлены happens-before, context, atomics, races/leaks/backpressure/shutdown |
| Go runtime, backend, gRPC, testing | P0 | DONE | Go 1.27 runtime/GC/profiling, HTTP, gRPC и test strategy |
| PostgreSQL | P0 | DONE | PostgreSQL 18: internals, queries, concurrency и operations |
| Redis | P1 | DONE | Redis 8.10: caching, memory, durability, HA, Cluster и locks |
| Kafka и messaging patterns | P0 | DONE | Kafka 4.3 KRaft, producer/consumer, EOS, Outbox/Inbox |
| Networking | P1 | DONE | Core protocols перепроверены по RFC; backend connections добавлены; external images удалены |
| Distributed systems и backend patterns | P0 | DONE | Consistency/failures + 14 reliability/data patterns |
| System Design | P1 | DONE | 15-step process, 17 fundamentals и 10 cases |
| Algorithms | P1 | DONE | 17 patterns + complexity + 10 annotated Go examples |
| Linux, Docker, Kubernetes | P1 | DONE | Linux ops, Docker rewrite, Kubernetes 1.37 lifecycle/resources |
| Observability и production | P0 | DONE | Signals/SLO + ordered diagnostic incident runbooks |
| Backend architecture и security | P1 | DONE | Boundaries/trade-offs; OWASP Top 10:2025, ASVS и IETF BCP |
| Practice project | P2 | DONE | Ads Service roadmap связывает contracts, data, reliability и operations |
| Interview references | P2 | DONE | Public AvitoTech materials checked 2026-09-10; variability disclosed |
| Final cross-links и content quality review | P0 | DONE | External images/legacy duplicate удалены; indexes, metadata, links и key claims проверены |

## Итог

Все обязательные batches мастер-плана завершены 2026-09-10. Новые темы после этой точки добавляются как обычное развитие базы, а не migration debt. Единственное ограничение проверки среды: Go toolchain не установлен, поэтому Go snippets прошли ручной review, но не полный compilation sweep.
