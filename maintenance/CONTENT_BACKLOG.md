# Content backlog

Статусы: `TODO`, `IN PROGRESS`, `DONE`. Приоритеты отражают риск неправильного применения материала, а не только объём темы.

| Topic | Priority | Status | Notes |
|---|---:|---|---|
| Batch 1 — migration foundation | P0 | DONE | 50 страниц перенесено, indexes пересобраны, legacy tree удалён после проверки |
| Go basics и strings/bytes/runes | P0 | IN PROGRESS | Удалить performance claim, исправить UTF-8 |
| Go slice и map | P0 | TODO | Map переписать под current stable Swiss Tables |
| Go interfaces, errors, panic/recover | P0 | TODO | Разделить guarantees и implementation |
| Go generics | P0 | TODO | Создать проверенный раздел под stable Go |
| Go memory model и concurrency | P0 | TODO | Исправить channel deadlock; добавить context/races/leaks |
| Go runtime, backend, gRPC, testing | P0 | TODO | Batch 3 |
| PostgreSQL | P0 | TODO | Locks переписать как PostgreSQL-specific |
| Redis | P1 | TODO | Создать раздел без универсализации Redlock |
| Kafka и messaging patterns | P0 | TODO | KRaft-only current architecture, producer semantics |
| Networking | P1 | TODO | Проверить факты, убрать критическую зависимость от external images |
| Distributed systems и backend patterns | P0 | TODO | Исправить CAP, добавить PACELC и failure modes |
| System Design | P1 | TODO | Разделить четыре большие заметки на связанные страницы |
| Algorithms | P1 | TODO | Паттерны и Go examples без dump решений |
| Linux, Docker, Kubernetes | P1 | TODO | Docker переписать с нуля |
| Observability и production | P0 | TODO | Диагностический порядок и SLO/error budgets |
| Backend architecture и security | P1 | TODO | Boundaries/trade-offs, OWASP primary sources |
| Practice project | P2 | TODO | Reference roadmap, не приложение в docs repo |
| Interview references | P2 | TODO | Только публичная актуальная информация |
| Final cross-links и content quality review | P0 | TODO | Устранить дубли, external images и unsupported claims |
