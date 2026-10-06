---
title: Load average
description: Runnable/uninterruptible tasks и правильная интерпретация.
tags: [linux, cpu]
updated: 2026-10-06
---

# Load average

Load average — сглаженное количество работающих/готовых задач и задач в непрерываемом ожидании. Это число задач, а не процент занятости CPU.

Linux load average — экспоненциально сглаженное число tasks, которые runnable (`R`) или находятся в uninterruptible sleep (`D`), примерно за 1, 5 и 15 минут. Это не CPU percentage.

```bash
cat /proc/loadavg
uptime
ps -eo state,pid,tid,comm,wchan:32 | awk '$1 ~ /^[RD]/'
```

Load 8 на 8 полностью доступных CPUs может означать занятый, но не обязательно перегруженный host; load 8 на одном CPU — очередь. Однако `D` tasks могут поднять load при низком CPU из-за storage/NFS/kernel wait. Compare с run queue, per-CPU utilization (доля занятого ресурса за интервал), PSI, I/O latency и task states.

В container host load average может отражать больше, чем один cgroup, а доступный CPU ограничен quota/cpuset. Поэтому деление host load на container CPU limit — только грубая эвристика. Используйте `cpu.stat`, throttling (принудительное ожидание после исчерпания квоты) и cgroup PSI.

1-minute value не простой average последней минуты, и значения реагируют с задержкой. Для alerting user latency/saturation обычно лучше, load — диагностический signal.

## Диагностический порядок

1. Подтвердить latency/throughput impact.
2. Проверить CPU utilization/run queue/throttling.
3. Найти `R` и `D` tasks/threads.
4. Для `D` проверить `wchan`, iostat, filesystem/network storage и kernel logs.
5. Correlate с deploy/traffic/recovery.

## Два разных случая с одинаковым load

```text
load average: 8.00, 6.00, 3.00
```

На 8 CPU восемь runnable tasks могут просто занимать доступную мощность. На 1 CPU они создают очередь. Но те же 8 могут быть D-state задачами, которые ждут NFS при почти idle CPU. Проверьте состояния через `ps` и wchan, затем соответствующий I/O и PSI.

В `/proc/loadavg` поле вида `4/350` отдельно показывает runnable/total tasks в момент чтения; это не то же самое, что сглаженная первая цифра. Значения за 1/5/15 минут помогают заметить тенденцию, но не заменяют p99 и реальные ограничения cgroup.

## Источники

- [proc_loadavg(5)](https://man7.org/linux/man-pages/man5/proc_loadavg.5.html)
- [Linux load averages](https://www.kernel.org/doc/html/latest/admin-guide/cpu-load.html)

## Проверь себя

1. Можно ли сказать load=4 означает CPU=400%?
2. Почему опасно делить host load на container quota?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, load считает задачи, включая D-state, и сглаживает их во времени.
2. У величин разный scope (область измерения: host, cgroup или process); host load может включать другие процессы.

</details>
