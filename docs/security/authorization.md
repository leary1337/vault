---
title: Authorization
description: Object-, function- и field-level access control, least privilege и policy enforcement.
tags: [security, authorization, access-control]
updated: 2026-09-10
---

# Authorization

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

## Источники

- [OWASP Authorization Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html)
- [OWASP Top 10:2025 — Broken Access Control](https://owasp.org/Top10/2025/A01_2025-Broken_Access_Control/)
- [OWASP API Security — Broken Object Level Authorization](https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/)

