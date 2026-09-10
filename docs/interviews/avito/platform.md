---
title: Platform interview
description: Подготовка по Go, runtime, concurrency, I/O и production behavior.
tags: [interviews, avito, platform, go]
updated: 2026-09-10
---

# Platform interview

В публичном отчёте AvitoTech 2025 platform-секция проверяет язык и его ecosystem через практические задачи, теоретические вопросы и чтение кода. Точный scope зависит от вакансии.

## Карта Go backend

- [language](../../go/language/README.md) и [data structures](../../go/data-structures/README.md);
- [concurrency](../../go/concurrency/README.md): memory model, ownership, cancellation, leaks;
- [runtime](../../go/runtime/README.md): scheduler, GC, allocation и GOMAXPROCS;
- [backend](../../go/backend/README.md): HTTP, context, deadlines, JSON, shutdown;
- [gRPC](../../go/grpc/README.md), [testing](../../go/testing/README.md), [profiling](../../go/performance/pprof.md).

## Формат тренировки

Читайте короткий fragment и отвечайте: что гарантирует spec, где race/deadlock/leak, кто владеет resource, как cancellation проходит вниз, что увидит caller и чем проверить в production. Затем сделайте минимальное исправление и назовите regression test.

Не учите scheduler как фиксированную внутреннюю схему. Гарантии memory model/API отделяйте от implementation, которая меняется между Go releases. Для performance утверждения называйте measurement и workload.
