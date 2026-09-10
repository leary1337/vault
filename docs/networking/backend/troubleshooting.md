---
title: Network troubleshooting
description: Диагностический порядок DNS, connect, TLS, HTTP и application latency.
tags: [networking, troubleshooting, production]
updated: 2026-09-10
---

# Network troubleshooting

«Network error» сначала раскладывают по stage и direction. Работайте с точными source/destination, protocol, timestamp, cohort и request ID; проверка с laptop не доказывает путь pod-а.

## Порядок

1. Подтвердить user impact и affected clients/regions/versions.
2. Проверить application error category и recent deploy/config/certificate/DNS/network-policy changes.
3. DNS: lookup outcome/latency, record/TTL, resolver и address family.
4. Connect: SYN/SYN-ACK/ACK outcome, timeout/refused/reset, route/firewall/NAT/ephemeral ports/backlog.
5. TLS: SNI, certificate/hostname/time/trust, alert и ALPN.
6. HTTP/RPC: protocol version, status, headers/body framing, proxy hop, stream reset/timeout.
7. Application: queue, handler и dependency spans — установленная connection не означает быстрый service.

## Симптомы

- `connection refused`: peer/port активно отклонил или локальный stack сообщил отсутствие listener; проверьте exact address и readiness.
- `connect timeout`: packets/drop/path/firewall/backlog могут быть причиной; capture с обеих сторон различает.
- `connection reset`: RST мог отправить endpoint, proxy или middlebox; сопоставьте timestamps.
- intermittent `EOF`: peer/proxy мог закрыть idle pooled connection; безопасный retry зависит от того, был ли request записан.
- DNS `NXDOMAIN` отличается от timeout/SERVFAIL и может кэшироваться.

## Tools и evidence

`dig`/`resolvectl`, `ss`, `/proc`/cgroup counters, `curl -v`, `openssl s_client`, `tcpdump`/Wireshark, `mtr` с осторожной интерпретацией, proxy/service metrics и distributed traces. Packet capture ограничивайте interface/host/port/time: payload может содержать PII/secrets, а TLS decryption material особенно чувствителен.

## Не делать первым

Не отключайте TLS validation, firewall или timeouts «для проверки» в production. Не увеличивайте retries/pools до определения bottleneck. Не делайте вывод о packet loss по ICMP response одного hop: control-plane ICMP может иметь иной priority, чем forwarded traffic.

После mitigation подтвердите recovery по SLI и сохраните stage-specific evidence для root cause.

