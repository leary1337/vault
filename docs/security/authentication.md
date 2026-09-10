---
title: Authentication
description: Sessions, tokens, MFA, credential lifecycle и authentication boundaries.
tags: [security, authentication, sessions]
updated: 2026-09-10
---

# Authentication

Authentication подтверждает identity через credential: пароль, session cookie, private key, passkey, client certificate или identity-provider token. Успешный login не даёт автоматического права на resource — далее нужна [authorization](authorization.md).

## Web session

Server-side session хранит state/revocation на сервере, browser получает случайный opaque ID. Cookie обычно должна иметь `Secure`, `HttpOnly`, подходящий `SameSite`, узкие `Domain`/`Path`; ID меняют после login и privilege change для защиты от fixation. Session получает idle и absolute expiry, explicit logout/revocation и server-side invalidation.

Cookie автоматически отправляется browser-ом, поэтому state-changing endpoints требуют [CSRF](backend-security.md#cors-и-csrf) защиты. Не помещайте credential в URL: он попадает в history, referrer и logs.

## Bearer token

Bearer token даёт доступ любому предъявителю. Передавайте его только по TLS, не логируйте, ограничивайте audience, scope и lifetime. Browser storage с JavaScript-доступом увеличивает ущерб XSS; HttpOnly cookie меняет риск на CSRF — универсально безопасного контейнера нет.

Access token короткоживущий и предназначен resource server; refresh token выдаёт новые access tokens только authorization server. Refresh token защищают в storage/transit, связывают с client/grant, ограничивают и отзывают; для public clients RFC 9700 требует replay detection через rotation либо sender-constrained tokens.

## Login defenses

- одинаковые внешние ответы/похожее время для unknown user и wrong password;
- rate limit по account, source/risk и global capacity без простого DoS-lockout;
- MFA/passkeys для чувствительных действий, step-up при повышении риска;
- reauthentication после recovery, credential change и high-risk operation;
- audit успешных/неуспешных событий без credential values;
- recovery не слабее основного login.

## Источники

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [OWASP Session Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html)
- [OAuth 2.0 Bearer Token Usage, RFC 6750](https://www.rfc-editor.org/rfc/rfc6750)

