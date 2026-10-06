---
title: "gRPC в Go"
description: "gRPC вызывает метод другого сервиса через сеть."
tags:
  - go
  - grpc
updated: 2026-10-06
---

# gRPC в Go

gRPC вызывает метод другого сервиса через сеть. Protobuf задаёт формат сообщений, контекст — срок и отмену, статус — категорию исхода. Сетевой отказ оставляет результат записи неизвестным: соединение и повторы сами эту проблему не устраняют.

`grpc.ClientConn` — долгоживущий клиентский канал. Он управляет разрешением имени, внутренними соединениями и балансированием; переиспользуйте его. По умолчанию `pick_first` выбирает одного доступного адресата, `round_robin` и другие правила задаются конфигурацией сервиса.

Кроме узких автоматических повторов, политика должна явно выбирать методы, коды, число попыток и защиту от повторного эффекта. Измеряйте отдельно логические вызовы и сетевые попытки.

## Темы

- [Сроки и отмена gRPC](deadlines-and-cancellation.md)
- [Ошибки gRPC](errors.md)
- [Перехватчики gRPC](interceptors.md)
- [Потоковые вызовы gRPC](streaming.md)
- [Контракты Protobuf](protobuf.md)
- [Unary RPC](unary.md)

## Источники

- [gRPC documentation](https://grpc.io/docs/)
- [Service Config](https://grpc.io/docs/guides/service-config/)
- [Custom load balancing policies](https://grpc.io/docs/guides/custom-load-balancing/)
