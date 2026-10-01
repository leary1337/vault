---
title: Testing Go-сервисов
description: Unit, integration, HTTP/DB, race, benchmark и fuzz testing.
tags:
  - go
  - testing
updated: 2026-09-10
---

# Testing Go-сервисов

Хороший набор тестов проверяет observable behavior на самом дешёвом подходящем уровне. Он не пытается заменить unit tests end-to-end тестами и не подменяет integration contract mocks.

## Темы

- [Benchmarks в тестах](benchmarks.md)
- [Database testing](database-testing.md)
- [Fuzzing](fuzzing.md)
- [HTTP testing](http-testing.md)
- [Integration tests](integration-tests.md)
- [Mocks, fakes и stubs](mocks-fakes-stubs.md)
- [Race detector в тестах](race-detector.md)
- [Table-driven tests](table-driven-tests.md)
- [Testcontainers for Go](testcontainers.md)
- [Unit tests](unit-tests.md)
