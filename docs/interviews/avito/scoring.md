---
title: Scoring / screening
description: Быстрая проверка инженерного фундамента и карта повторения.
tags: [interviews, avito, screening]
updated: 2026-10-01
---

# Scoring / screening

Публичный материал AvitoTech 2023 года называл скрининг входным получасовым техническим собеседованием по основам. Публичный отчёт 2025 говорит о предварительных тестировании и телефонных интервью, но не фиксирует универсальный syllabus. Ниже собраны связанные темы для обсуждения; это не подтверждённый список вопросов компании.

## Что повторить

- [Go language](../../go/language/README.md): values, methods, interfaces, errors, slices/maps;
- [PostgreSQL](../../databases/postgresql/README.md): transactions, MVCC, indexes, query plan;
- [Networking](../../networking/README.md): TCP, HTTP, DNS, TLS;
- [Distributed systems](../../distributed-systems/README.md): consistency, replication, failures;
- [Backend patterns](../../backend-patterns/README.md): retry, idempotency, backpressure.

## Как отвечать

За 2–3 минуты дайте определение, mechanism, одну гарантию, failure mode и production example. Если вопрос version-sensitive, назовите boundary или скажите, что проверили бы документацию. Не подменяйте спецификацию случайной runtime implementation detail.

Тренировка: 20 вопросов по 90 секунд, затем разберите ответы без источника, с неверной причинностью или без trade-off. Цель — быстро обнаружить пробел, не изображать абсолютную уверенность.

Это пример самостоятельной репетиции, а не подтверждённый формат screening компании.

## Источники

- [AvitoTech: публикация 2023, раздел «Собеседования»](https://habr.com/ru/companies/avito/articles/774696/)
- [AvitoTech: Weekend Offer 2025](https://habr.com/ru/companies/avito/articles/919020/)

