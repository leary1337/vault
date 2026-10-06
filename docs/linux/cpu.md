---
title: CPU
description: Utilization, saturation, throttling и profiling.
tags: [linux, cpu, production]
updated: 2026-10-06
---

# CPU

Загрузка CPU говорит, занят ли процессор, а насыщение — есть ли очередь готовых задач. Оба сигнала нужны: одно горячее ядро может ограничивать сервис на большой машине.

CPU utilization (доля занятого ресурса за интервал) показывает долю времени по states за интервал; saturation (очередь работы, которая ждёт ресурс) — runnable work, которая ждёт CPU. 100% одного core может ограничивать single-threaded shard при низкой host average.

`user` — userspace, `system` — kernel, `irq/softirq` — interrupt work, `steal` — время, отнятое hypervisor. `iowait` — CPU idle при ожидающемся I/O и не является точной долей времени process «ждал диск».

## Диагностика

```bash
mpstat -P ALL 1
pidstat -u -w -p "$PID" 1
top -H -p "$PID"
cat /proc/pressure/cpu
perf stat -p "$PID"
perf record -F 99 -g -p "$PID" -- sleep 30
```

Сначала подтвердите user impact и scope (область измерения: host, cgroup или process). Разделите high utilization от throttling (принудительное ожидание после исчерпания квоты) (`cpu.stat`), run queue/PSI, context switches и one-core hotspot. Затем profile representative interval: CPU profile отвечает «где выполнялись cycles», а wall profile/trace — «где ждём».

`perf` может требовать privileges и symbols; sampling добавляет overhead. Не оптимизируйте функцию только по total CPU без traffic/output: рост CPU может быть следствием полезной нагрузки, retry storm, GC, serialization или spin.

## Context и containers

cgroup `cpu.max` задаёт quota/period и вызывает throttling даже при idle host cores; `cpu.weight` распределяет contention, не задаёт абсолютный reserve. Kubernetes CPU request обычно влияет на scheduling/weight, limit — на quota.

## Низкое среднее может скрывать проблему

Пример: у host 16 CPU, одна последовательная goroutine постоянно занимает один. Средняя utilization около 6,25%, но этот участок уже не может обработать больше без изменения алгоритма/параллелизма. Проверьте `mpstat -P ALL 1`, потоки процесса и Go CPU profile.

Если контейнер использует quota 1 CPU на том же host, он может испытывать throttling, хотя остальные 15 CPU свободны. Сравните прирост `nr_throttled`/`throttled_usec` между двумя чтениями cpu.stat и пользовательскую задержку за тот же интервал. Не трактуйте `iowait=40%` как «конкретный процесс 40% ждал диск»: это состояние CPU с ограничениями учёта.

## Источники

- [proc_stat(5)](https://man7.org/linux/man-pages/man5/proc_stat.5.html)
- [perf-stat(1)](https://man7.org/linux/man-pages/man1/perf-stat.1.html)

## Проверь себя

1. Почему host CPU 10% не исключает CPU bottleneck?
2. Чем saturation отличается от utilization?

<details>
<summary>Ориентиры для ответа</summary>

1. Одно ядро/последовательный участок или container quota уже могут быть насыщены.
2. Saturation — очередь готовой работы; utilization — занятое процессорное время.

</details>
