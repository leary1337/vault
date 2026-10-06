---
title: Backend security
description: Identity, transport, secrets и защита backend boundaries.
tags: [security, backend, owasp]
updated: 2026-10-06
---

# Backend security

Безопасность начинается с конкретных вопросов: кто обращается к сервису, какие действия ему разрешены и какие данные он может подменить. Здесь разобраны вход в систему, права на объекты, токены, пароли, секреты и защищённые соединения. Примеры показывают, почему успешная аутентификация ещё не разрешает чужие ресурсы.

Security — набор проверяемых свойств системы, а не middleware в конце проекта. Сначала моделируют assets, actors, trust boundaries и abuse cases; затем применяют least privilege, secure defaults, defense in depth и observable failure handling.

OWASP Top 10:2025 — awareness baseline, не исчерпывающий checklist. Для конкретной системы добавьте threat model, supply-chain controls, secure SDLC, incident response и отраслевые требования.


## Темы

- [Authentication](authentication.md)
- [Authorization](authorization.md)
- [Backend security controls](backend-security.md)
- [JWT](jwt.md)
- [OAuth 2.0 и OpenID Connect](oauth2-and-oidc.md)
- [Passwords](passwords.md)
- [Secrets management](secrets.md)
- [TLS](tls.md)

## Базовый принцип

Authentication отвечает «кто/что предъявило credential», authorization — «разрешено ли конкретное действие над конкретным resource сейчас». Любой network caller и client-supplied field недоверенны; внутренний адрес сам по себе не identity.

## Источники

- [OWASP Top 10:2025](https://owasp.org/Top10/)
- [OWASP Application Security Verification Standard](https://owasp.org/www-project-application-security-verification-standard/)

