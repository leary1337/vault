---
title: TLS
description: Transport authentication, TLS configuration, certificate validation и termination boundaries.
tags: [security, tls, networking]
updated: 2026-09-10
---

# TLS

TLS обеспечивает confidentiality, integrity и authentication peer-а согласно выбранной схеме. Он не исправляет authorization, injection или компрометацию endpoint-а.

## Server baseline

Используйте TLS 1.3 и, при необходимости совместимости, TLS 1.2 с современными implementations/configuration; старые protocol versions отключайте. Certificate должен соответствовать hostname, цепочка — доверенному anchor, сроки — действительны. Автоматизируйте issuance/renewal и alert до expiry.

Не копируйте статический cipher list без учёта версии library/platform. TLS 1.3 определяет другой набор suites; предпочтения и deprecations меняются. Используйте поддерживаемые secure defaults и регулярно проверяйте external scanner/config policy.

## Client validation

Client проверяет chain, hostname, validity и назначение certificate. `InsecureSkipVerify`/отключение validation не допустимо как production fix. Private PKI требует управляемого trust store и rotation, а не принятия любого self-signed certificate.

Mutual TLS аутентифицирует workload/client certificate, но mapping certificate identity к application permissions остаётся authorization задачей. Планируйте выдачу, короткий lifetime, rotation и revocation.

## Termination и proxies

При TLS termination за load balancer граница доверия перемещается туда. Защитите hop до backend по threat model; очищайте incoming forwarding headers и принимайте их только от trusted proxy. HSTS применим к browser HTTPS после проверки deployment, включая subdomains/preload consequences.

Не логируйте session keys или plaintext payload без строго ограниченной incident procedure. TLS metadata тоже раскрывает часть информации; certificate/private key — [secret](secrets.md).

## Источники

- [TLS 1.3, RFC 8446](https://www.rfc-editor.org/rfc/rfc8446)
- [Recommendations for Secure Use of TLS and DTLS, RFC 9325](https://www.rfc-editor.org/rfc/rfc9325)
- [OWASP Transport Layer Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Security_Cheat_Sheet.html)

