---
title: TLS
description: TLS 1.3 handshake, record protection, certificate validation и resumption.
tags: [networking, tls, cryptography]
updated: 2026-09-10
---

# TLS

TLS защищает transport channel: confidentiality, integrity и authentication peer-а согласно выбранному credential/policy. SSL 2.0/3.0 и старые TLS versions исторические и не должны описываться как современный вариант.

## TLS 1.3 handshake

ClientHello предлагает versions, cipher suites, key shares, extensions, SNI и ALPN. ServerHello выбирает параметры; после key agreement handshake сообщения защищены. Server отправляет certificate chain, CertificateVerify доказывает владение private key, Finished связывает transcript. Client проверяет chain, hostname, validity, key usage и policy до доверия peer-у.

TLS 1.3 использует (EC)DHE для обычного full handshake и AEAD record protection; старый RSA key transport не является TLS 1.3 flow. Симметричные traffic keys выводятся через HKDF и меняются независимо по направлениям.

## Records и границы

Record layer фрагментирует и защищает данные, но application message boundaries задаёт верхний protocol. TLS скрывает content, не все metadata: addresses, timing, sizes и часть handshake информации могут быть видимы. TLS не делает недоверенный payload безопасным для parser-а.

## Resumption и 0-RTT

После handshake server может выдать session tickets для PSK resumption. Это уменьшает setup cost, но tickets/keys имеют lifecycle и rotation. 0-RTT early data replayable: server не может дать обычную replay protection TLS; разрешайте только явно replay-safe semantics или отключайте.

## Certificates и operations

Certificate связывает public key с names/identity через issuer chain. Автоматизируйте issuance/renewal, защищайте private keys, поддерживайте overlap и alert до expiry. mTLS подтверждает client certificate, но authorization mapping остаётся application policy.

Диагностика: точные hostname/SNI, clock, chain/intermediates, trust store, protocol/cipher, ALPN, alert и termination hop. Никогда не отключайте verification как production mitigation. См. [TLS security](../../security/tls.md).

## Источники

- [TLS 1.3, RFC 8446](https://www.rfc-editor.org/rfc/rfc8446)
- [Secure use of TLS, RFC 9325](https://www.rfc-editor.org/rfc/rfc9325)
