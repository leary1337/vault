---
title: Scoring / screening
description: Быстрая проверка инженерного фундамента и карта повторения.
tags: [interviews, avito, screening]
updated: 2026-09-10
---

# Scoring / screening

Публичный материал AvitoTech 2023 года называл скрининг входным получасовым техническим собеседованием по основам. Публичный отчёт 2025 говорит о предварительных тестировании и телефонных интервью, но не фиксирует универсальный syllabus. Поэтому ниже — тренировочный маршрут, а не список реальных вопросов.

## Что повторить

- [Go language](../../go/language/README.md): values, methods, interfaces, errors, slices/maps;
- [PostgreSQL](../../databases/postgresql/README.md): transactions, MVCC, indexes, query plan;
- [Networking](../../networking/README.md): TCP, HTTP, DNS, TLS;
- [Distributed systems](../../distributed-systems/README.md): consistency, replication, failures;
- [Backend patterns](../../backend-patterns/README.md): retry, idempotency, backpressure.

## Как отвечать

За 2–3 минуты дайте определение, mechanism, одну гарантию, failure mode и production example. Если вопрос version-sensitive, назовите boundary или скажите, что проверили бы документацию. Не подменяйте спецификацию случайной runtime implementation detail.

Тренировка: 20 вопросов по 90 секунд, затем разберите ответы без источника, с неверной причинностью или без trade-off. Цель — быстро обнаружить пробел, не изображать абсолютную уверенность.

