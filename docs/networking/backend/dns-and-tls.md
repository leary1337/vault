---
title: DNS и TLS на critical path
description: Resolver caching, stale addresses, TLS 1.3 handshake, resumption и 0-RTT.
tags: [networking, dns, tls]
updated: 2026-09-10
---

# DNS и TLS на critical path

## DNS resolution

Application может обращаться через stub resolver, OS service, local cache и recursive resolver; caching существует на нескольких уровнях и зависит от runtime/platform. Positive TTL задаётся DNS data, negative caching имеет отдельную semantics. Нельзя предполагать, что client мгновенно увидит новый address после DNS change.

Для connection pool DNS обычно применяется при создании нового connection, не для уже открытого. Долгоживущие connections могут пережить rotation endpoint-а; lifetime/drain и retry должны согласовываться с service discovery. Слишком частый lookup увеличивает latency/load, слишком долгий собственный cache удерживает stale адреса.

Измеряйте lookup latency/outcome, returned address family, cache layer, connect outcome по IP и timestamp. Не используйте DNS round-robin как гарантию равномерной нагрузки: resolver/client caching и connection reuse меняют distribution.

## TLS 1.3 handshake

После TCP (для HTTP/1.1/2) client отправляет ClientHello с versions, cipher suites, extensions, SNI и ALPN; server выбирает параметры, предоставляет certificate chain и доказательство private key, стороны выводят traffic keys. Client обязан проверить chain, hostname, validity и policy. ALPN выбирает, например, `h2` или `http/1.1`.

TLS 1.3 full handshake обычно позволяет application data после одного network round trip сверх transport establishment. Session resumption через PSK уменьшает cryptographic/setup cost. 0-RTT early data может быть replayed и не имеет полной forward secrecy для early data: допускайте только операции с безопасной replay semantics и explicit server policy.

QUIC интегрирует TLS 1.3 handshake с transport establishment; HTTP/3 избегает отдельного TCP handshake, но UDP reachability/fallback и connection migration добавляют свои состояния.

## Operations

Разделяйте DNS, connect и TLS latency/errors. Проверяйте clock, SNI/hostname, chain/intermediate, trust store, certificate expiry, ALPN, proxy termination и MTU/firewall. Connection reuse скрывает handshake cost в steady state, поэтому cold-start и reconnect storm тестируются отдельно.

См. [TLS security](../../security/tls.md), [DNS protocol](../application/dns.md) и [TLS protocol](../application/tls.md).

## Источники

- [DNS concepts and facilities, RFC 1034](https://www.rfc-editor.org/rfc/rfc1034)
- [TLS 1.3, RFC 8446](https://www.rfc-editor.org/rfc/rfc8446)
- [QUIC-TLS, RFC 9001](https://www.rfc-editor.org/rfc/rfc9001)

