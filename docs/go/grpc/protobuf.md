---
title: Protobuf contracts
description: Field numbers, presence, compatibility и безопасная эволюция Protobuf schema.
tags:
  - go
  - grpc
  - protobuf
updated: 2026-10-06
---

# Protobuf contracts

Protobuf описывает поля сообщения и их устойчивые числовые номера. По этим номерам разные версии программы понимают один бинарный поток.

Field number — wire (передаваемый по сети) identity. После публикации его нельзя менять или переиспользовать для другого смысла.

```proto
message User {
  string id = 1;
  optional string display_name = 2;
  reserved 3, 4;
  reserved "legacy_name";
}
```

При удалении reserve number и name. Добавление поля обычно binary wire-safe: старый reader сохраняет/игнорирует unknown field по правилам implementation, но бизнес-логика должна корректно обрабатывать default/absence.

Presence различается для scalar fields, `optional`, message и `oneof`; не используйте zero value, если нужно отличить «не передано» от «передано ноль». Enum должен иметь zero value с безопасной семантикой (`UNSPECIFIED`).

Binary protobuf compatibility не равна ProtoJSON compatibility. Меняя schema, проверяйте оба формата, если JSON используется в gateway/storage. Не переименовывайте field как «безопасную» операцию, если clients зависят от JSON names.

Generated Go code не редактируется вручную. Фиксируйте версии `protoc`/plugins и проверяйте breaking changes в CI.

## Ноль и отсутствие в API обновления

```proto
syntax = "proto3";

message UpdateAd {
  string id = 1;
  optional int64 price_minor = 2;
}
```

`price_minor` хранит цену в минимальных денежных единицах. Если поле отсутствует, цену не меняем; если передано 0, делаем объявление бесплатным. Обычный scalar без presence не позволяет надёжно различить эти намерения. В сгенерированном Go API используйте предусмотренный механизм presence: открытый и opaque API могут выглядеть по-разному.

Изменение `int32` на `int64` может быть wire-compatible по кодированию, но старый reader способен потерять большие значения. Совместимость означает также бизнес-смысл, диапазон, JSON и порядок развёртывания. Удалённые номера reserve; неизвестные поля не должны исчезнуть из посредника, который обязан передавать исходное сообщение дальше.

## Источники

- [Proto3 language guide](https://protobuf.dev/programming-guides/proto3/)
- [Proto best practices](https://protobuf.dev/best-practices/dos-donts/)
- [ProtoJSON format](https://protobuf.dev/programming-guides/json/)

## Проверь себя

1. Почему нельзя переиспользовать удалённый номер?
2. Когда нужен optional scalar?

<details>
<summary>Ориентиры для ответа</summary>

1. Старые данные/клиенты прочтут новое поле как прежний смысл.
2. Когда отсутствие отличается от явно переданного zero value, например PATCH цены.

</details>
