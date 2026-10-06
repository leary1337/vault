---
title: Platform interview
description: Подготовка по Go, runtime, concurrency, I/O и production behavior.
tags: [interviews, avito, platform, go]
updated: 2026-10-06
---

# Platform interview

Платформенная секция проверяет, понимаете ли вы поведение Go-кода и сервиса при конкуренции, отмене и отказах. Сильный ответ связывает строку кода с наблюдаемым эффектом.

В публичном отчёте AvitoTech 2025 platform-секция проверяет язык и его ecosystem через практические задачи, теоретические вопросы и чтение кода. Точный scope зависит от вакансии.

## Карта Go backend

- [language](../../go/language/README.md) и [data structures](../../go/data-structures/README.md);
- [concurrency](../../go/concurrency/README.md): memory model, ownership, cancellation, leaks;
- [runtime](../../go/runtime/README.md): scheduler, GC, allocation и GOMAXPROCS;
- [backend](../../go/backend/README.md): HTTP, context, deadlines, JSON, shutdown;
- [gRPC](../../go/grpc/README.md), [testing](../../go/testing/README.md), [profiling](../../go/performance/pprof.md).

## Формат тренировки

Читайте короткий fragment и отвечайте: что гарантирует spec, где race/deadlock/leak, кто владеет resource, как cancellation проходит вниз, что увидит caller и чем проверить в production. Затем сделайте минимальное исправление и назовите regression test.

Не учите scheduler как фиксированную внутреннюю схему. Гарантии memory model/API отделяйте от implementation, которая меняется между Go releases. Для performance утверждения называйте measurement и workload.

## Пример чтения кода: забытый ответ HTTP

```go
resp, err := client.Get(url)
if err != nil {
    return err
}
return json.NewDecoder(resp.Body).Decode(&result)
```

Это фрагмент с готовыми client/url/result; не самостоятельная программа. Не закрыт resp.Body; request не использует context вызывающего, timeout зависит от client; HTTP500 не превращается автоматически в err. Исправление: NewRequestWithContext, проверка статуса, defer Body.Close и ограничение размера ответа согласно контракту. Для повторного использования HTTP/1 соединения обычно нужно прочитать body до EOF и закрыть; бесконтрольное drain большого тела тоже ошибка.

После исправления назовите проверку: httptest server с задержкой должен прерываться по deadline, ответ500 не декодируется как успешный бизнес-ответ, oversized body отклоняется. Для production смотрите active connections, pool waits и latency downstream, а не объявляйте любой рост памяти leak.

Различайте гарантии spec и детали реализации: map order не гарантирован; форма внутренней таблицы меняется. GOMAXPROCS ограничивает исполнение Go-кода одновременно, а не все OS threads. Ответ senior на уточнение «всегда ли?» называет точную границу гарантии.

## Проверь себя

1. **HTTP500 возвращается как client.Do error?**

   <details>
   <summary>Ответ</summary>

   Обычно нет: err описывает запрос/transport; status проверяет приложение.

   </details>

2. **Чем проверять предположение о leak?**

   <details>
   <summary>Ответ</summary>

   Воспроизведение, goroutine/heap profiles и lifecycle ресурсов; одна растущая метрика недостаточна.

   </details>
