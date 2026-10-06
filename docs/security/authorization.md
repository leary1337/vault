---
title: Authorization
description: Object-, function- и field-level access control, least privilege и policy enforcement.
tags: [security, authorization, access-control]
updated: 2026-10-06
---

# Authorization

Авторизация проверяет право выполнить действие над конкретным ресурсом сейчас. Роль — лишь один вход проверки; важны также tenant, владелец, состояние объекта и поля, которые меняет запрос.

## Термины в этой статье

- **tenant** — изолированная организация или группа пользователей в многопользовательском сервисе.
- **identity** — подтверждённая личность пользователя или службы.
- **scope** — заявленный объём доступа, который всё ещё требует проверки политикой сервера.

Authorization решает, может ли authenticated principal выполнить action над resource в текущем context. Проверка нужна server-side на каждом request/message, включая object и field level; скрытая кнопка или непредсказуемый ID не являются control.

## Модели

- RBAC связывает роли с permissions; прост, но разрастается комбинациями ролей.
- ABAC использует attributes principal/resource/context; выразителен, сложнее тестировать.
- ReBAC проверяет отношения в graph: owner, member, parent; требует продуманной consistency.
- capability/token делегирует узкое право предъявителю; leakage становится критичным.

Реальные системы комбинируют модели. Policy описывает business permission (`edit_ad`), а не только route/method.

## Enforcement

Централизуйте решение policy, но применяйте его у каждой trust boundary. Запрашивайте resource по `id AND tenant_id`, если это соответствует модели, вместо load-then-forget-check. Проверяйте nested resources, bulk operations, exports, admin endpoints и async consumers.

Deny by default. Не доверяйте role/tenant/owner из body; берите identity из проверенного authentication context, resource attributes — из authoritative storage. Cache решения только с ключом, включающим все policy inputs, и понятной invalidation.

## Изменения и audit

Permission change, suspension и ownership transfer требуют определённой propagation/revocation semantics. Audit записывает actor, effective subject/impersonation, action, target, decision, policy version и outcome без secrets.

Тестируйте матрицу positive/negative cases и cross-tenant IDOR/BOLA. Особое внимание — новые endpoints: OWASP Top 10:2025 сохраняет Broken Access Control на первом месте.

## Разбор на примере

Пользователь tenant A знает ID объявления tenant B. Проверка «пользователь вошёл» не предотвращает BOLA/IDOR — доступ к чужому объекту по идентификатору. Поиск и изменение должны учитывать trusted identity, а не tenant из body.

```sql
UPDATE ads
SET price = $1, version = version + 1
WHERE id = $2 AND tenant_id = $3 AND owner_id = $4
  AND version = $5;
```

Здесь `$3/$4` получены из проверенного контекста; SQL иллюстрирует политику «менять может только владелец» и optimistic concurrency. Ноль строк может означать отсутствие права, объекта или конфликт версии. Внешний ответ выбирают с учётом риска раскрытия существования объекта; нельзя автоматически считать всё конфликтом.

При переназначении owner отдельно прочитанное разрешение может устареть до UPDATE. Для критичного invariant согласуйте проверку и mutation одной transaction/условием; кеш permissions не исправляет race. Проверяйте bulk export, вложения и background consumer: политика нужна не только HTTP middleware.

Минимальная матрица тестов: свой объект/чужой объект, другой tenant, другой owner, запрещённое поле, отозванное право, отсутствие identity, административный обход с audit. UUID затрудняет угадывание, но не является механизмом разрешения.

## Источники

- [OWASP Authorization Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html)
- [OWASP Top 10:2025 — Broken Access Control](https://owasp.org/Top10/2025/A01_2025-Broken_Access_Control/)
- [OWASP API Security — Broken Object Level Authorization](https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/)


## Проверь себя

1. Почему role=editor может быть недостаточно?
2. Как защититься от смены owner между проверкой и записью?

<details>
<summary>Ответы</summary>

1. Нужно проверить scope роли, tenant, ownership, object state и конкретное поле.

2. Согласовать permission predicate и mutation атомарно либо обеспечить нужную transaction/locking semantics.

</details>
