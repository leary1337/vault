---
title: Idempotency в System Design
description: Logical operation identity через API, queue и storage.
tags: [system-design, reliability]
updated: 2026-10-06
---

# Idempotency в System Design

Одна бизнес-операция сохраняет один ID через повторы, очереди и внешнего поставщика.

Проследите одну logical operation через client retry, proxy retry, queue redelivery и consumer (потребитель работы или контракта) restart. На каждой границе должен сохраняться stable identity.

## Проектирование

- Client/API idempotency key scoped by tenant + operation.
- Request fingerprint запрещает reuse key с другим payload (полезное содержимое запроса или события).
- Durable state `processing/succeeded/failed` задаёт concurrent/ambiguous behavior.
- Database unique key или version transition делает mutation atomic с marker.
- Event ID не меняется при outbox/producer retry.
- Consumer inbox/business key deduplicate-ит redelivery.
- External provider получает тот же key или обрабатывается reconciliation (сверка и устранение расхождений).

Retention (срок хранения) покрывает максимальный offline retry, broker retention/replay и restore window. Если это слишком долго, естественный business ID/state machine лучше временной dedup table.

## Проверка дизайна

Тестируйте crash до и после каждого durable point и потерю response. Определите response duplicate запроса в `processing`, permanent failure и payload conflict. Не храните sensitive full response без access/retention policy.

Идемпотентность не означает отсутствие concurrent conflict: две разные keys могут менять один aggregate. Нужны constraints, optimistic version или isolation. Подробнее: [idempotency pattern](../../backend-patterns/idempotency.md).

## На конкретном примере

Для создания ad idempotency scope включает tenant, caller и тип операции. Key при том же body возвращает прежний результат, при другом — документированную ошибку. Fingerprint строится по нормализованным значимым полям, а не случайному JSON-порядку. Ответ не отдаётся другому пользователю только потому, что он угадал key.

Запись `processing` для долгой работы требует lease/recovery; запись для короткого локального create можно commit (фиксация результата, который считается подтверждённым) вместе с окончательным результатом. Удаление ключа через сутки разрешает старому retry создать повтор: это часть окна гарантии.

## Источник механизма

[HTTP: идемпотентные методы](https://www.rfc-editor.org/rfc/rfc9110.html#name-idempotent-methods). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему key должен иметь scope?
2. Что делать после срока dedup retention?

<details>
<summary>Ориентиры для ответа</summary>

1. Чтобы операции разных tenants/пользователей не столкнулись и не раскрыли ответ.
2. Нельзя обещать прежнюю защиту; нужен domain ID или запрет поздних повторов.

</details>
