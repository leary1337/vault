# Проверка сетей и безопасности — 2026-10-06

Проверены и содержательно расширены 26 тематических страниц `docs/networking` и 8 `docs/security`. Обзорные страницы служат тематическими индексами. Во всех тематических статьях добавлены понятный ввод, конкретный сценарий или расчёт и два вопроса с раскрываемыми ответами. Схемы описывают протоколы и доверительные границы, а не обязательный порядок изучения.

## Существенные исправления и детализация

- TCP: поток байтов, отсутствие границ сообщений, rwnd/cwnd, ACK против бизнес-подтверждения. UDP connect не создаёт сетевой handshake; QUIC разделяет потоки, но сохраняет общие ограничения congestion control.
- HTTP: условный запрос с устаревшим If-Match возвращает 412, атомарность проверки версии; различия TCP HOL и независимых QUIC streams, QPACK blocking, границы GOAWAY и повторов.
- DNS/TLS: TTL относится к cache, а не к уже открытым соединениям; негативное кэширование, hostname и trust chain, 0-RTT replay, отдельное TLS-соединение каждого hop.
- IP: адрес следующего узла на канальном уровне отличается от конечного IP; prefix routing, PMTU/ICMP, IPv6 router fragmentation, диагностические команды и ограничения capture offload.
- Authentication/authorization: session rotation, серверная проверка tenant/owner, конкурентное изменение прав, ограничения cookie и MFA.
- JWT/OIDC: фиксированная политика issuer/audience/algorithm, доверенный JWKS, ID token против access token, opaque access token; PKCE, state, nonce и refresh rotation решают разные задачи.
- Passwords/secrets: Argon2 memory budget с явными единицами, bcrypt limit в байтах, recovery и ротация секрета с подтверждением применения.
- SSRF: проверка actual destination, перенаправлений и DNS rebinding; CORS не заменяет CSRF и авторизацию.

Четыре прежние обзорные статьи сетевого фундамента переписаны: модель TCP/IP, путь пакета, стандартизация и терминология. Исправлены утверждения о MAC как неизменяемом адресе и портах как идентификаторах процесса.

## Первичные источники

Проверка выполнена по HTTP RFC 9110/9112/9113/9114; TCP RFC 9293; QUIC RFC 9000; UDP RFC 8085; TLS RFC 8446; IPv6 RFC 8200; DNS negative caching RFC 2308; DHCP RFC 2131 и DHCPv6 RFC 9915; IANA port registry, IETF RFC process, Linux kernel IP sysctl docs и man7 ip(7). Точные ссылки сохранены в статьях.

Безопасность сверена с OAuth Security BCP RFC 9700, JWT BCP RFC 8725, OpenID Connect Core, NIST SP 800-63B-4 и первичными OWASP Cheat Sheets по authentication, sessions, authorization, password storage, SSRF и secrets.

## Границы проверки

Примеры сетевых адресов относятся к документируемым диапазонам. Расчёты явно задают throughput, RTT, MTU и время ожидания; цифры не являются результатом benchmark. Linux-команды, сетевые capture и окружение private PKI на данном Windows-host не запускались. SQL-проверка прав иллюстрирует атомарный predicate и не является готовым repository implementation. Содержательная сверка источников не означает аудит безопасности реального сервиса.
