---
title: JWT
description: JWT validation, claims, revocation и trade-offs относительно opaque tokens.
tags: [security, jwt, tokens]
updated: 2026-09-10
---

# JWT

JSON Web Token — compact container claims, обычно JWS-signed, иногда JWE-encrypted. Base64url encoding не шифрует payload: не помещайте туда секреты или лишнее PII.

## Validation contract

Verifier заранее знает допустимый token kind, issuer, audience и algorithms. Он проверяет cryptographic signature, `iss`, `aud`, `exp`, при необходимости `nbf`, и application claims. Не выбирайте algorithm по недоверенному `alg` без allowlist; не принимайте `none`; не смешивайте access, ID, email-verification и reset tokens одним validation path.

Header parameters (`kid`, `jku`, `x5u`) недоверенны. Key lookup ограничен configured issuer/key set; иначе возможны SSRF и key confusion. Rotation должна поддерживать overlap старого ключа до истечения выданных tokens.

## Trade-offs

Signed JWT позволяет локальную проверку без network hop и переносит ограниченные claims. Цена — revocation и stale authorization: уже выданный token живёт до expiry. Большой token увеличивает headers; содержимое раскрывается holder-у; изменение roles не мгновенно.

Opaque token с introspection/server-side session проще немедленно отозвать и скрывает claims, но создаёт storage/network dependency. Выбирайте по revocation, scale и trust boundaries, не по моде.

## Практика access/refresh

Короткий access token ограничивает окно утечки. Refresh token — высокоценный credential; часто лучше opaque, хранить только защищённое представление, rotation/reuse detection и grant-family revocation. Logout должен иметь честную semantics: удаление browser copy не отзывает JWT во всех resource servers.

Не кладите быстро меняющиеся permissions в долгоживущий JWT. Проверяйте критичную authorization по authoritative state или используйте короткий TTL/versioning.

## Источники

- [JSON Web Token, RFC 7519](https://www.rfc-editor.org/rfc/rfc7519)
- [JWT Best Current Practices, RFC 8725](https://www.rfc-editor.org/rfc/rfc8725)
- [OWASP JWT Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html)

