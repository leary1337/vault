---
title: TLS
description: Transport authentication, TLS configuration, certificate validation и termination boundaries.
tags: [security, tls, networking]
updated: 2026-10-06
---

# TLS

Защита TLS требует правильной проверки peer, актуальных ключей и явно обозначенных точек termination. Шифрование без проверки identity может защищать соединение с атакующим.

## Термины в этой статье

- **identity** — подтверждённая личность пользователя или службы.
- **endpoint** — конкретный адрес службы или сторона соединения.
- **rotation** — замена ключа или секрета с прекращением использования предыдущего.
- **revocation** — досрочный отзыв ранее выданного доступа.
- **proxy** — посредник, который принимает соединение или запрос и передаёт его дальше.
- **payload** — полезные данные сообщения, без служебных заголовков.
- **mTLS** — TLS с проверкой сертификатов обеих сторон.

TLS обеспечивает конфиденциальность, целостность обмена и проверку стороны соединения. Он не заменяет проверку прав, защиту от внедрения команд и безопасность самих участников обмена.

## Server baseline

Используйте TLS 1.3, а при необходимости совместимости — TLS 1.2 с современными библиотеками и настройками. Старые версии отключайте. Сертификат должен соответствовать имени сервера и срокам действия, а цепочка — приводить к доверенному корню. Автоматизируйте выпуск, продление и предупреждение до истечения срока.

Не копируйте статический cipher list без учёта версии library/platform. TLS 1.3 определяет другой набор suites; предпочтения и deprecations меняются. Используйте поддерживаемые secure defaults и регулярно проверяйте external scanner/config policy.

## Client validation

Клиент проверяет цепочку доверия, имя, сроки и назначение сертификата. `InsecureSkipVerify` не исправляет причину сбоя и выключает необходимые проверки. Для внутреннего центра сертификации (private PKI) нужен управляемый набор доверенных корней и процедура их замены; нельзя принимать любой самоподписанный сертификат.

Mutual TLS аутентифицирует workload/client certificate, но mapping certificate identity к application permissions остаётся authorization задачей. Планируйте выдачу, короткий lifetime, rotation и revocation.

## Termination и proxies

При TLS termination за load balancer граница доверия перемещается туда. Защитите hop до backend по threat model; очищайте incoming forwarding headers и принимайте их только от trusted proxy. HSTS применим к browser HTTPS после проверки deployment, включая subdomains/preload consequences.

Не логируйте session keys или plaintext payload без строго ограниченной incident procedure. TLS metadata тоже раскрывает часть информации; certificate/private key — [secret](secrets.md).

## Разбор на примере

Клиент подключается к сервису через private PKI. Правильное решение — настроить доверенный CA и проверить hostname/назначение, не `InsecureSkipVerify`. Самоподписанность не единственный вопрос: неправильный trusted CA, name mismatch и истёкший intermediate требуют разных исправлений.

В mTLS обе стороны проверяют сертификаты. После этого приложение отображает certificate identity на разрешённые действия: сертификат сервиса `analytics` не разрешает операции `billing` автоматически. Trusted forwarding header с identity допустим только через защищённый и проверенный proxy path.

Сертификат истекает через 7 дней, но метрика renewal зелёная только на одном pod. Проверяйте фактически выдаваемый сертификат на всех termination points, SAN, expiry, chain и reload. Успешное получение нового файла ещё не доказывает его использование listener.

TLS 1.3 ciphertext не защищает от SQL injection, утечки уже расшифрованных данных в log или неограниченного body. Протокол transport security закрывает свою границу, остальные controls остаются необходимыми. Подробнее об обмене: [TLS в сетях](../networking/application/tls.md).

## Источники

- [TLS 1.3, RFC 8446](https://www.rfc-editor.org/rfc/rfc8446)
- [Recommendations for Secure Use of TLS and DTLS, RFC 9325](https://www.rfc-editor.org/rfc/rfc9325)
- [OWASP Transport Layer Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Security_Cheat_Sheet.html)


## Проверь себя

1. Что mTLS доказывает и чего не разрешает автоматически?
2. Почему успешный renewal job ещё не доказывает устранение expiry риска?

<details>
<summary>Ответы</summary>

1. Владение соответствующим клиентским credential и доверенную identity по policy; права на ресурс проверяются отдельно.

2. Нужно проверить фактически обслуживаемый сертификат после reload на каждой точке termination.

</details>
