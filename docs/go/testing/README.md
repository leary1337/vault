---
title: Testing Go-сервисов
description: Unit, integration, HTTP/DB, race, benchmark и fuzz testing.
tags:
  - go
  - testing
updated: 2026-09-10
---

# Testing Go-сервисов

Порядок чтения: [unit tests](unit-tests.md) → [table-driven tests](table-driven-tests.md) → [test doubles](mocks-fakes-stubs.md) → [integration tests](integration-tests.md). Затем выберите boundary: [HTTP](http-testing.md), [database](database-testing.md), [race detector](race-detector.md), [benchmarks](benchmarks.md), [fuzzing](fuzzing.md), [Testcontainers](testcontainers.md).

Хороший набор тестов проверяет observable behavior на самом дешёвом подходящем уровне. Он не пытается заменить unit tests end-to-end тестами и не подменяет integration contract mocks.
