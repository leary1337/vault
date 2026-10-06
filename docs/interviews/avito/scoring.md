---
title: Scoring / screening
description: Быстрая проверка инженерного фундамента и карта повторения.
tags: [interviews, avito, screening]
updated: 2026-10-06
---

# Scoring / screening

Короткий технический ответ должен объяснить механизм, а не только дать название. Формат и конкретный scope предварительной секции уточняются для вакансии.

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

## Пример ответа: «что даёт индекс»

«Индекс — отдельная структура для поиска адресов строк. B-tree подходит equality/range/order. Для списка заказов клиента индекс(customer_id,created_at DESC,id DESC) сужает диапазон по клиенту и даёт порядок без отдельного sort. Он стоит места, WAL и работы записи. На маленькой таблице либо при чтении большей части строк Seq Scan может быть дешевле. Проверю EXPLAIN с representative параметрами, actual rows, buffers и write cost».

Этот ответ содержит определение, механизм, пример, границу и проверку. Недостаточный вариант — «индекс всегда ускоряет поиск O(log n)»: реальный query может читать множество heap rows, сортировать, ждать locks; сложность поиска ключа не описывает весь запрос.

Если не помните default конкретного Go client, назовите, что проверять: transport ownership, timeouts, retry semantics и version. Не заменяйте отсутствие точной цифры уверенным предположением. Уточняющий вопрос полезнее ответа на другую задачу: «речь о записи на primary или чтении replica?»

## Источники

- [AvitoTech: публикация 2023, раздел «Собеседования»](https://habr.com/ru/companies/avito/articles/774696/)
- [AvitoTech: Weekend Offer 2025](https://habr.com/ru/companies/avito/articles/919020/)


## Проверь себя

1. **Как превратить термин в инженерный ответ?**

   <details>
   <summary>Ответ</summary>

   Определение → механизм → пример → ограничение → способ проверить.

   </details>

2. **Почему O(log n) поиска индекса не равно latency SQL?**

   <details>
   <summary>Ответ</summary>

   Запрос включает heap fetches, фильтрацию, sort, locks и передачу результата.

   </details>
