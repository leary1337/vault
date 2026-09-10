---
title: Load average
description: Runnable/uninterruptible tasks и правильная интерпретация.
tags: [linux, cpu]
updated: 2026-09-10
---

# Load average

Linux load average — экспоненциально сглаженное число tasks, которые runnable (`R`) или находятся в uninterruptible sleep (`D`), примерно за 1, 5 и 15 минут. Это не CPU percentage.

```bash
cat /proc/loadavg
uptime
ps -eo state,pid,tid,comm,wchan:32 | awk '$1 ~ /^[RD]/'
```

Load 8 на 8 полностью доступных CPUs может означать занятый, но не обязательно перегруженный host; load 8 на одном CPU — очередь. Однако `D` tasks могут поднять load при низком CPU из-за storage/NFS/kernel wait. Compare с run queue, per-CPU utilization, PSI, I/O latency и task states.

В container host load average может отражать больше, чем один cgroup, а доступный CPU ограничен quota/cpuset. Поэтому деление host load на container CPU limit — только грубая эвристика. Используйте `cpu.stat`, throttling и cgroup PSI.

1-minute value не простой average последней минуты, и значения реагируют с задержкой. Для alerting user latency/saturation обычно лучше, load — диагностический signal.

## Диагностический порядок

1. Подтвердить latency/throughput impact.
2. Проверить CPU utilization/run queue/throttling.
3. Найти `R` и `D` tasks/threads.
4. Для `D` проверить `wchan`, iostat, filesystem/network storage и kernel logs.
5. Correlate с deploy/traffic/recovery.

## Источники

- [proc_loadavg(5)](https://man7.org/linux/man-pages/man5/proc_loadavg.5.html)
- [Linux load averages](https://www.kernel.org/doc/html/latest/admin-guide/cpu-load.html)
