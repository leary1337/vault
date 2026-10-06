---
title: API design
description: Contracts, errors, idempotency, pagination и evolution.
tags: [system-design, api]
updated: 2026-10-06
---

# API design

API задаёт смысл результата, а не только имена JSON-полей.

API — долгоживущий contract (договорённость о поведении и гарантиях) между failure domains. Он должен выражать resource/state transition, concurrency и retry semantics, а не отражать внутренние tables.

## Контракт

- stable identifiers и tenant scope;
- schema с required/optional fields и validation limits;
- explicit error model: retryable, permanent, conflict, rate limited;
- deadline/cancellation propagation;
- authorization на object/action, а не только endpoint;
- pagination с deterministic order и cursor;
- compatibility policy и deprecation window.

Для create/side-effect command примите idempotency key. Для optimistic update используйте version/ETag и conditional write. `202 Accepted` означает принятие asynchronous job, а не завершение; верните operation ID/status endpoint.

Offset pagination проста, но нестабильна при изменениях и дорога на больших offsets. Keyset cursor кодирует sort key + unique tie-breaker и filter/version context.

## Развитие контракта

Добавление optional field обычно совместимо, изменение смысла/типа — нет. Consumers должны игнорировать неизвестные fields, но producers не должны переиспользовать удалённое поле с новым смыслом. В event API schema evolution и retention (срок хранения) старых событий требуют отдельной проверки.

## Вопросы про отказы

- Может ли server завершить operation после client timeout?
- Как client узнаёт status ambiguous request?
- Что произойдёт при duplicate/out-of-order call?
- Где ограничены body, fan-out (раздача одного действия многим получателям) и expensive filters?
- Что логируется без утечки secrets/PII?

## На конкретном примере

Пример: GET объявления вернул `ETag: "v7"`. PATCH с `If-Match: "v7"` не перезапишет v8 и получит 412. Конфликт статуса «продано, редактирование запрещено» может быть 409. `202` возвращает ID операции и URL проверки статуса, поэтому повторный клиент не создаёт второй job.

Для списка 50 элементов используем сортировку `(created_at DESC,id DESC)` и продолжение по обоим значениям. Новый объект может появиться до курсора — это нормальная семантика keyset, не снимок. Если требуется фиксированный набор, курсор ссылается на ограниченную по времени сессию/снимок.

## Источник механизма

[HTTP semantics](https://www.rfc-editor.org/rfc/rfc9110.html). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему 202 не означает выполнено?
2. Что включить в cursor?

<details>
<summary>Ориентиры для ответа</summary>

1. Это подтверждение приёма, результат нужно получить отдельно.
2. Все ключи сортировки, уникальный ID и контекст фильтра/сессии.

</details>
