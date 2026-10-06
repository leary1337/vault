---
title: Testing Go-сервисов
description: Unit, integration, HTTP/DB, race, benchmark и fuzz testing.
tags:
  - go
  - testing
updated: 2026-10-06
---

# Testing Go-сервисов

Тест проверяет обещанное поведение на подходящей границе. Unit проверяет небольшую логику, integration — настоящие протоколы и хранилища, race — выполненные конкурентные обращения, fuzz — свойства на новых входах. Самый дешёвый тест выбирают по ошибке, которую он должен обнаружить.

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
