---
title: Security в System Design
description: Threat model, identity, authorization, data и abuse controls.
tags: [system-design, security]
updated: 2026-09-10
---

# Security в System Design

Security review начинается с assets, actors, trust boundaries и abuse cases. TLS rectangle без authorization/data lifecycle не является design.

## Checklist

- Authentication: human/service identity, credential lifecycle, MFA/workload identity.
- Authorization: deny by default, object/tenant/action checks на server, least privilege.
- Transport/storage: TLS, encryption at rest, key rotation и ownership.
- Secrets: dedicated secret store, short-lived credentials, no logs/images/repos.
- Input/output: size/schema validation, injection-safe APIs, SSRF allowlists, safe file handling.
- Data: classification, minimization, retention/delete, backup and telemetry copies.
- Abuse: rate/cost limits, enumeration resistance, replay/idempotency, moderation.
- Supply chain: pinned/verifiable artifacts, dependency scanning, controlled deploy.
- Audit: tamper-resistant security events с ограниченным доступом.

Multi-tenant key/cache/index обязательно включает tenant boundary; ID угадываемого объекта не является authorization. Background jobs и admin endpoints проходят те же проверки.

## Failure и operations

Определите поведение при недоступности identity/policy service: fail-open редко допустим для privileged action. Rotation должна работать без synchronized restart. Incident plan включает revoke credentials, isolate component, preserve evidence и уведомление владельцев данных.

Threat model пересматривают при новом data flow/provider. Используйте актуальные OWASP ASVS/API Security guidance как checklist, но привязывайте control к конкретной угрозе.

## Источники

- [OWASP API Security Top 10](https://owasp.org/API-Security/)
- [NIST SP 800-207 Zero Trust Architecture](https://csrc.nist.gov/publications/detail/sp/800-207/final)
