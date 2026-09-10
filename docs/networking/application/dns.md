---
title: DNS
description: Иерархическая система имён, recursive resolution, caching и backend failure modes.
tags: [networking, dns]
updated: 2026-09-10
---

# DNS

DNS — distributed hierarchical database, сопоставляющая names с typed records. Authoritative server хранит данные zone; recursive resolver выполняет/кэширует поиск от имени client-а. Stub resolver приложения обычно обращается к настроенному recursive service.

## Resolution и records

Для имени могут использоваться `A`/`AAAA`, alias `CNAME`, mail `MX`, service metadata `SRV`, delegation `NS`, policy/text `TXT`. Alias и target создают несколько lookup/cache steps. DNS не проверяет, что application на returned IP готово.

Resolver кэширует ответ по TTL. Negative response тоже может кэшироваться по SOA-defined semantics. TTL не гарантирует одновременное обновление клиентов: lookup мог выполняться раньше, а существующий pooled connection вообще не делает новый DNS query.

UDP широко используется, но response с truncation ведёт к TCP; zone transfers используют TCP, а encrypted DNS может идти по TLS/HTTPS/QUIC. Нельзя диагностировать DNS только одним transport assumption.

## Consistency и изменения

До смены endpoint-а уменьшите TTL заранее, затем учитывайте старые cache entries и connection draining. После change наблюдайте queries/answers и connect success по returned IP. Round-robin ordering не гарантирует равномерный request balancing из-за caches, address selection и connection reuse.

DNSSEC даёт origin authentication/integrity DNS data, но не шифрует queries и не заменяет TLS certificate validation. Split-horizon/search suffix и `/etc/hosts` могут дать разные ответы в pod, node и laptop.

## Диагностика

Различайте `NXDOMAIN`, `SERVFAIL`, timeout и empty/no-data response. Фиксируйте resolver, queried name/type, response code, TTL, addresses, latency и затем connect/TLS outcome. Подробнее: [DNS и TLS на critical path](../backend/dns-and-tls.md).

## Источники

- [DNS concepts, RFC 1034](https://www.rfc-editor.org/rfc/rfc1034)
- [DNS implementation, RFC 1035](https://www.rfc-editor.org/rfc/rfc1035)
- [Negative caching, RFC 2308](https://www.rfc-editor.org/rfc/rfc2308)
