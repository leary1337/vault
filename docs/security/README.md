---
title: Backend security
description: Identity, transport, secrets и защита backend boundaries.
tags: [security, backend, owasp]
updated: 2026-09-10
---

# Backend security

Security — набор проверяемых свойств системы, а не middleware в конце проекта. Сначала моделируют assets, actors, trust boundaries и abuse cases; затем применяют least privilege, secure defaults, defense in depth и observable failure handling.

## Порядок изучения

1. [Authentication](authentication.md) и [authorization](authorization.md).
2. [Passwords](passwords.md), sessions и tokens.
3. [OAuth 2.0 и OpenID Connect](oauth2-and-oidc.md), затем [JWT](jwt.md).
4. [TLS](tls.md) и [secrets](secrets.md).
5. [Backend security](backend-security.md): CORS, CSRF, SSRF и injection defenses.

OWASP Top 10:2025 — awareness baseline, не исчерпывающий checklist. Для конкретной системы добавьте threat model, supply-chain controls, secure SDLC, incident response и отраслевые требования.

## Базовый принцип

Authentication отвечает «кто/что предъявило credential», authorization — «разрешено ли конкретное действие над конкретным resource сейчас». Любой network caller и client-supplied field недоверенны; внутренний адрес сам по себе не identity.

## Источники

- [OWASP Top 10:2025](https://owasp.org/Top10/)
- [OWASP Application Security Verification Standard](https://owasp.org/www-project-application-security-verification-standard/)

