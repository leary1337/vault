---
title: Profile-guided optimization
description: Сбор representative CPU profile и воспроизводимое применение PGO.
tags:
  - go
  - performance
  - pgo
updated: 2026-10-06
---

# Profile-guided optimization

PGO использует профиль обычной нагрузки, чтобы компилятор лучше выбирал оптимизации. Это подсказка сборке, а не изменение семантики программы.

PGO позволяет compiler использовать CPU profile representative production workload при inlining и devirtualization decisions.

Типовой flow:

1. Собрать CPU profile стабильной версии под типичной нагрузкой.
2. Сохранить его как `default.pgo` в main package или передать `go build -pgo=profile.pprof`.
3. Собрать и проверить новую версию обычными tests/load tests.
4. Обновлять profile периодически, не на каждом request/deploy автоматически.

Profile — build input: храните provenance, workload и Go version; не включайте чувствительные labels/paths. Нерепрезентативный profile может оптимизировать не тот path. PGO не заменяет исправление алгоритма и измерение end-to-end outcome.

## Контрольная сборка обязательна

```bash
go build -pgo=off -o service-baseline ./cmd/service
go build -pgo=cpu.pprof -o service-pgo ./cmd/service
```

`cpu.pprof` — заранее собранный CPU profile вашей программы. Обе сборки проверяют на одинаковых данных и нагрузке: latency, CPU на запрос, errors, memory. Например, профиль одного редкого batch endpoint не представляет API с 95% коротких GET. Полезен provenance: версия кода, дата, доля операций, hardware и способ сбора.

Профиль может перестать быть представительным после изменения traffic или большого refactoring. Он не обязан совпадать построчно с новой программой, но эффект нужно заново измерять. Отсутствие выигрыша — допустимый результат эксперимента.

## Источники

- [Profile-guided optimization](https://go.dev/doc/pgo)

## Проверь себя

1. Можно ли взять профиль другого сервиса ради ускорения?
2. Чем доказывать пользу PGO?

<details>
<summary>Ориентиры для ответа</summary>

1. Он не описывает ваши горячие пути; нужен representative профиль вашего workload.
2. Контрольной сборкой и измерением одинаковой нагрузки, включая корректность.

</details>
