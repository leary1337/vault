---
title: Protobuf contracts
description: Field numbers, presence, compatibility и безопасная эволюция Protobuf schema.
tags:
  - go
  - grpc
  - protobuf
updated: 2026-09-10
---

# Protobuf contracts

Field number — wire identity. После публикации его нельзя менять или переиспользовать для другого смысла.

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

## Источники

- [Proto3 language guide](https://protobuf.dev/programming-guides/proto3/)
- [Proto best practices](https://protobuf.dev/best-practices/dos-donts/)
- [ProtoJSON format](https://protobuf.dev/programming-guides/json/)
