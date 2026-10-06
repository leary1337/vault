# Проверка Linux, Docker и Kubernetes

Дата: 2026-10-06. Прочитаны полностью и обновлены все 36 существующих страниц `docs/linux/**` и `docs/containers/**`: 32 предметных статьи, 4 индекса. В каждой предметной статье — понятная вводная, предметный пример/расчёт или диагностический сценарий, два вопроса и скрываемые ориентиры ответа. Пути сохранены; учебный обязательный порядок не вводился.

## Изменения

Linux: quota/time units, hierarchical cgroup limits, отличие CPU utilization от saturation, R/S/D/Z states, zombie reaping, exec close-on-exec, FD/dup/offset, RSS/PSS/VSZ, page cache, OOM vs SIGKILL, TCP framing, readiness vs completion и ET чтение до EAGAIN. В диагностике добавлены интерпретации условного вывода и конкретные проверяемые гипотезы.

Docker: команды run с limits/security, конкретные ENTRYPOINT/CMD результаты, секрет в нижнем layer, host-vs-container loopback, CGO/architecture runtime requirements, tmpfs/swap и backup/volume различия, exec-wrapper и бюджет остановки. Existing multi-stage Go Dockerfile сохранён с уточнёнными предпосылками.

Kubernetes: полный Deployment пример, согласование labels/Service/named port, request/surge calculation, probe budgets/cascade, ConfigMap/Secret update/rotation, Pod shared namespaces/sidecars, EndpointSlices termination, HPA metric formula и downstream pool pressure. Исправлены incomplete HPA metadata и overly broad inherited claims: PDB не блокирует обычный Deployment scale-down; ошибочная metric может блокировать downscale, но не всякий upscale. Scale-to-zero имеет отдельную точную версионную границу.

Добавлено 10 вручную написанных Mermaid-схем: три Linux и семь containers. Родительский агент добавил официальный SVG Kubernetes components; в Kubernetes README включены alt, ссылка и атрибуция Kubernetes contributors / CC BY 4.0. Генерация raster изображений не использовалась.

## Baseline и первичные источники

Kubernetes baseline 1.37; официальная release page на дату проверки указывает 1.37.1 от 2026-09-15. Статья не превращает текущий release в гарантию установленного provider cluster. Go image baseline 1.27.1 сохранена как конкретная версия примера, без заявления latest. У Docker/Linux не заявлена одна универсальная версия: поведение зависит от kernel/runtime/storage/network plugin.

- [Kubernetes releases](https://kubernetes.io/releases/): версия 1.37.1.
- [HPA documentation](https://kubernetes.io/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale/): formula/metrics/failure handling, scale-to-zero beta since 1.37; gate HPAScaleToZero, object/external requirement.
- [Pod lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/): grace/preStop/stop signal ordering.
- [EndpointSlices](https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/): ready/serving/terminating.
- [Pod resource management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/): requests/limits, CPU vs memory, Pod accounting.
- [Probe configuration](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/): startup/readiness/liveness и действие failures.
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/): RUN/ENTRYPOINT/CMD и stages.
- [Docker resource constraints](https://docs.docker.com/engine/containers/resource_constraints/): memory/CPU/PID controls.
- [Kernel cgroup v2](https://docs.kernel.org/admin-guide/cgroup-v2.html): hierarchy, cpu.max/stat, memory accounting/events.
- [epoll manual](https://man7.org/linux/man-pages/man7/epoll.7.html): LT/ET/nonblocking/readiness.
- [execve manual](https://man7.org/linux/man-pages/man2/execve.2.html): process replacement и FD_CLOEXEC.
- [proc_loadavg manual](https://man7.org/linux/man-pages/man5/proc_loadavg.5.html): load fields и R/D tasks.

Страницы также сохраняют предметные ссылки на Linux man-pages, Docker и Kubernetes docs для дальнейшей перепроверки конкретных механизмов.

## Проверки и пределы

Проверены local paths/metadata через repository checker и whitespace через `git diff --check`; общий checker в середине совместной работы временно обнаруживал ошибки в algorithms вне этой области. Последний общий checker на момент завершения этой области прошёл: 316 pages / 315 SUMMARY entries; git diff --check прошёл. Родительский агент повторяет финальную проверку после объединения всех правок.

На Windows нет Docker/kubectl/Linux kernel для этих экспериментов. Команды, YAML, Dockerfile и иллюстративный output **не заявляются выполненными**. YAML-примеры отделены от fragments, external image/app paths помечены как fixtures, численные расчёты проверены вручную. Не выполнялись `kubectl apply`, container smoke, real CNI/Ingress termination tests, memory/cgroup load experiments, image vulnerability scans или deployment. Эти сценарии требуют соответствующего окружения и приложения.

Официальная документация используется для API и поведения, а не для обещания полного покрытия каждого интервью. Понятное чтение и самопроверка не гарантируют автоматическое запоминание или опыт эксплуатации.
