---
title: OAuth 2.0 и OpenID Connect
description: Делегированная авторизация, login, code flow, PKCE и token validation.
tags: [security, oauth2, oidc]
updated: 2026-09-10
---

# OAuth 2.0 и OpenID Connect

OAuth 2.0 делегирует доступ к protected resource; сам по себе это не login protocol. OpenID Connect (OIDC) добавляет authentication layer, ID Token, UserInfo и discovery поверх OAuth 2.0.

## Роли и токены

- resource owner разрешает доступ;
- client запрашивает разрешение;
- authorization server аутентифицирует/получает consent и выдаёт tokens;
- resource server принимает access token для конкретного API.

ID Token сообщает client-у результат authentication и claims о пользователе; его нельзя использовать как произвольный access token к API. Access token audience — resource server. Refresh token предъявляется только token endpoint.

## Рекомендуемый redirect flow

Используйте Authorization Code Grant с PKCE (`S256`) для public и современных confidential clients. `state` связывает response с browser transaction/CSRF defense; OIDC `nonce` связывает ID Token и защищает от replay. Redirect URI сравнивают строго с зарегистрированной. Implicit grant и Resource Owner Password Credentials не используйте: RFC 9700 считает их небезопасными/не рекомендует.

Backend callback должен однократно обменять code вместе с `code_verifier`, проверить issuer, client, redirect URI и protocol errors. Не отправляйте code/token в analytics и logs.

## Validation

Принимать ID/access token значит как минимум проверить signature/approved algorithm, issuer, audience, expiry/not-before и token type/purpose. OIDC client дополнительно проверяет `nonce` и flow-specific claims. Keys получают из trusted issuer metadata/JWKS с cache и безопасной rotation; `kid` не является URL для произвольной загрузки.

Scopes ограничивают делегированный доступ, но не заменяют object-level authorization. Запрашивайте минимальные scopes/audiences. Refresh tokens ограничивайте grant-ом, защищайте, истекайте/отзывайте; public clients используют rotation или sender constraint для replay detection.

## Источники

- [OAuth 2.0 Security Best Current Practice, RFC 9700](https://www.rfc-editor.org/rfc/rfc9700)
- [OpenID Connect Core 1.0 with errata](https://openid.net/specs/openid-connect-core-1_0.html)
- [PKCE, RFC 7636](https://www.rfc-editor.org/rfc/rfc7636)

