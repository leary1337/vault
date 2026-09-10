---
title: CPU
description: Utilization, saturation, throttling и profiling.
tags: [linux, cpu, production]
updated: 2026-09-10
---

# CPU

CPU utilization показывает долю времени по states за интервал; saturation — runnable work, которая ждёт CPU. 100% одного core может ограничивать single-threaded shard при низкой host average.

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

Сначала подтвердите user impact и scope. Разделите high utilization от throttling (`cpu.stat`), run queue/PSI, context switches и one-core hotspot. Затем profile representative interval: CPU profile отвечает «где выполнялись cycles», а wall profile/trace — «где ждём».

`perf` может требовать privileges и symbols; sampling добавляет overhead. Не оптимизируйте функцию только по total CPU без traffic/output: рост CPU может быть следствием полезной нагрузки, retry storm, GC, serialization или spin.

## Context и containers

cgroup `cpu.max` задаёт quota/period и вызывает throttling даже при idle host cores; `cpu.weight` распределяет contention, не задаёт абсолютный reserve. Kubernetes CPU request обычно влияет на scheduling/weight, limit — на quota.

## Источники

- [proc_stat(5)](https://man7.org/linux/man-pages/man5/proc_stat.5.html)
- [perf-stat(1)](https://man7.org/linux/man-pages/man1/perf-stat.1.html)
