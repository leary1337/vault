---
title: Network troubleshooting
description: Диагностический порядок DNS, connect, TLS, HTTP и application latency.
tags: [networking, troubleshooting, production]
updated: 2026-10-06
---

# Network troubleshooting

Диагностика сети — проверка конкретного пути и стадии отказа. Начните с того, где ожидание остановилось: поиск имени, соединение, TLS, HTTP или обработка запроса.

## Термины в этой статье

- **SNI** — имя сервера, которое клиент передаёт во время установки TLS.
- **ALPN** — согласование прикладного протокола во время установки защищённого соединения.
- **proxy** — посредник, который принимает соединение или запрос и передаёт его дальше.
- **endpoint** — конкретный адрес службы или сторона соединения.
- **payload** — полезные данные сообщения, без служебных заголовков.
- **namespace** — изолированная область системных ресурсов, например собственная таблица сетевых интерфейсов.

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

## Разбор на примере

Симптом: только один pod получает connect timeout. С ноутбука endpoint доступен. Это не исключает NetworkPolicy, другой DNS resolver, route/NAT или IPv6 именно этого pod.

```bash
curl -sS -o /dev/null -w 'dns=%{time_namelookup} connect=%{time_connect} tls=%{time_appconnect} first=%{time_starttransfer} total=%{time_total}
' https://api.example.test/health
```

Значения curl накопительные от старта transfer: TLS-стадию при обычном последовательном connect оценивают разностью `time_appconnect - time_connect`, не суммой двух чисел. DNS 0.010, connect 0.050, appconnect 0.090, first 0.600 означает около 40 мс TCP, 40 мс TLS и затем 510 мс до первого байта; последняя часть может содержать proxy/очередь/handler. Это учебный trace.

Далее из affected network namespace сравните A/AAAA и конкретные IP, SYN/SYN-ACK с обеих сторон, policy и recent changes. Для HTTPS запрос на IP без сохранения hostname/SNI меняет проверяемую задачу; используйте `curl --resolve` с исходным именем. Один capture только на клиенте не доказывает, кто отбросил пакет.

## Проверь себя

1. Нужно ли складывать time_connect и time_appconnect?
2. Почему успешный запрос с ноутбука не исключает сетевой отказ сервиса?

<details>
<summary>Ответы</summary>

1. Нет, это накопительные времена; для отдельных стадий берут подходящие разности.

2. Он идёт другим путём, resolver, namespace, policy и адресной семьёй.

</details>
