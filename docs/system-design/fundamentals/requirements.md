---
title: Functional requirements
description: Actors, use cases, invariants и границы scope.
tags: [system-design, requirements]
updated: 2026-09-10
---

# Functional requirements

Functional requirement описывает наблюдаемое поведение, а не component: «пользователь может отозвать ссылку», а не «используем Redis».

Зафиксируйте:

- actors и trust boundaries;
- основные commands/queries и приоритетный happy path;
- state machine и запрещённые transitions;
- business invariants и uniqueness;
- edge cases: duplicate, concurrent update, delete, expiry, retry;
- admin/moderation/audit workflows;
- явно исключённый scope.

Пример для notification service: создать notification с idempotency key; применить user preferences; доставить по разрешённым channels; показать status; retry transient error; не отправлять после unsubscribe. «Exactly once delivery» замените проверяемым контрактом — например, at-least-once enqueue и provider-level idempotency где возможно.

Приоритизируйте requirements (must/should/later). Иначе design пытается одновременно оптимизировать несовместимые сценарии. Для каждого must-use-case укажите owner данных, источник истины и observable success.

## Checklist

- Как client идентифицирует одну logical operation?
- Какие действия reversible?
- Что можно обработать asynchronous?
- Как долго данные/события нужны?
- Что видит пользователь при partial failure?
