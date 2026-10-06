---
title: Functional requirements
description: Actors, use cases, invariants и границы scope.
tags: [system-design, requirements]
updated: 2026-10-06
---

# Functional requirements

Функциональное требование описывает действие и ожидаемый результат, не выбранную технологию.

Functional requirement описывает наблюдаемое поведение, а не component: «пользователь может отозвать ссылку», а не «используем Redis».

Зафиксируйте:

- actors и trust boundaries;
- основные commands/queries и приоритетный happy path;
- state machine и запрещённые transitions;
- business invariants и uniqueness;
- edge cases: duplicate, concurrent update, delete, expiry, retry;
- admin/moderation/audit workflows;
- явно исключённый scope.

Пример для notification service: создать notification с idempotency key; применить user preferences; доставить по разрешённым channels; показать status; retry transient (временный, потенциально устранимый повтором) error; не отправлять после unsubscribe. «Exactly once delivery» замените проверяемым контрактом — например, at-least-once enqueue и provider-level idempotency где возможно.

Приоритизируйте requirements (must/should/later). Иначе design пытается одновременно оптимизировать несовместимые сценарии. Для каждого must-use-case укажите owner данных, источник истины и observable success.

## Вопросы для проверки

- Как client идентифицирует одну logical operation?
- Какие действия reversible?
- Что можно обработать asynchronous?
- Как долго данные/события нужны?
- Что видит пользователь при partial failure?

## На конкретном примере

Плохое требование: «Kafka, Redis, microservices». Проверяемое: «после подтверждения нового сообщения оно доступно при переподключении; повтор с прежним client_message_id возвращает прежнее сообщение». Здесь уже есть durable граница и ID операции.

Для ad фиксируем draft→pending→published→closed. Изменение текста после проверки требует новой модерации либо публикации только одобренной версии. Тест требования отправляет старый результат модерации после нового редактирования и проверяет, что новое содержание не опубликовано.

## Источник механизма

[HTTP semantics: подтверждение операций](https://www.rfc-editor.org/rfc/rfc9110.html). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему выбор БД не functional requirement?
2. Что делает state machine полезной?

<details>
<summary>Ориентиры для ответа</summary>

1. Это способ реализации, а не наблюдаемая возможность.
2. Она перечисляет допустимые и запрещённые переходы, включая конкуренцию.

</details>
