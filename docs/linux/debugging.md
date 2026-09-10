---
title: Linux debugging workflow
description: Диагностический порядок и практические команды backend engineer.
tags: [linux, debugging, production]
updated: 2026-09-10
---

# Linux debugging workflow

Не начинайте с restart и случайного списка команд. Сначала зафиксируйте symptom, impact, time window, scope (host/container/process/thread) и recent changes; затем переходите от дешёвых широких сигналов к узким invasive tools.

## 1. Process и saturation

```bash
ps -eo pid,ppid,stat,etimes,%cpu,%mem,rss,comm --sort=-%cpu
top -H -p "$PID"          # htop — интерактивная альтернатива
vmstat 1
cat /proc/pressure/{cpu,memory,io}
```

Определите CPU, runnable/D-state tasks, context switches, reclaim/swap и scope cgroup.

## 2. Memory и kernel

```bash
free -h
cat /proc/$PID/smaps_rollup
dmesg -T | tail -200
```

Ищите OOM, allocation/reclaim, page faults и kernel/device errors. `dmesg` может требовать privilege и содержать sensitive addresses.

## 3. Disk/I/O

```bash
iostat -xz 1
pidstat -d -p "$PID" 1
lsof -p "$PID"
```

Сопоставьте throughput, latency, queue/utilization с process files; `%util` semantics зависят от device/parallelism и не заменяют await/PSI.

## 4. Network/FD

```bash
ss -s
ss -lntp
ss -tanp
lsof -nP -p "$PID"
```

Проверяйте listen/connection states, retransmits отдельными network tools/metrics, FD limits и ephemeral ports.

## 5. Syscalls и profiles

```bash
strace -f -tt -T -p "$PID"
perf top -p "$PID"
perf record -F 99 -g -p "$PID" -- sleep 30
```

Используйте кратко после baseline: attach/sampling меняют систему. Для Go сопоставьте с pprof/runtime trace.

## Завершение

Immediate mitigation отделяйте от root cause. Сохраните timestamps, commands/outputs, hypothesis и before/after metrics. Проверка исправления должна воспроизвести тот же workload/signal, а prevention — добавить limit, test, alert или design change.
