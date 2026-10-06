---
title: Layered architecture
description: Слои presentation, application, domain и infrastructure и цена их связности.
tags: [architecture, layers]
updated: 2026-10-06
---

# Layered architecture

Слой группирует ответственность: перевод запроса, координация операции, бизнес-правила, доступ к внешним системам.

Layered architecture группирует код по роли. Типичный поток: transport/presentation → application/service → domain → data/infrastructure. В строгом варианте верхний слой зависит только от следующего; в relaxed варианте может обращаться через несколько слоёв.

## Границы

- transport преобразует HTTP/gRPC/message contract (договорённость о поведении и гарантиях) в application command/query;
- application координирует use case, transaction и external effects;
- domain хранит business rules и invariants;
- infrastructure реализует SQL, cache, broker и remote clients.

DTO (структура данных внешнего запроса/ответа) transport-а не должен незаметно становиться domain model и database row одновременно: это связывает API evolution, storage schema и invariants. Ошибки переводятся на boundary: domain error → стабильный API status, а не утечка SQL текста.

## Компромиссы

Плюсы: низкий порог входа, понятный request flow, достаточно для большинства CRUD/service applications. Риски: «толстый service», anemic domain, горизонтальные папки с сотнями unrelated types, обход слоёв и зависимость business logic от framework.

Layering по техническим папкам ухудшает locality feature changes. Практичный вариант — сначала разделить bounded (с явным конечным пределом) modules/features, затем использовать небольшие слои внутри каждого.

## Когда не усложнять

Для небольшого stateless adapter (адаптер конкретной технологии к контракту) достаточно handler + client и тестов contract. Интерфейс на каждый package и четыре mapping layers без независимых моделей создают ceremony, не границу.

## Механизм на примере

Пример PATCH цены: handler проверяет формат/аутентификацию; application service проверяет право владельца и запускает транзакцию; domain запрещает отрицательную цену и изменение закрытого объявления; SQL adapter делает UPDATE с версией. Проверка владельца только в handler пропадёт, когда появится Kafka consumer (потребитель работы или контракта) того же use case.

Можно хранить DTO и доменную модель одним типом для простого CRUD, если семантика действительно совпадает. Разделение нужно при разных правилах: поле API `price` не равно внутреннему `price_minor + currency`. Не делаем mapper ради папки, но и не даём JSON `status=published` обходить правило модерации.

## Источник механизма

[Martin Fowler: Service Layer](https://martinfowler.com/eaaCatalog/serviceLayer.html). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Куда поместить правило публикации?
2. Нужно ли всегда четыре модели данных?

<details>
<summary>Ориентиры для ответа</summary>

1. В общую бизнес/application границу, используемую всеми transports.
2. Нет, только при разных смыслах и независимых причинах изменения.

</details>
