---
title: Backend Knowledge Base
description: Русскоязычная база знаний по Go и backend-разработке.
tags:
  - backend
updated: 2026-09-10
---

# Backend Knowledge Base

Это постоянно обновляемая база знаний для Go backend-разработчиков уровня Middle+ и Senior. Она подходит для последовательного изучения, быстрого повторения, разбора production-механизмов и подготовки к техническим обсуждениям.

Сейчас в базе доступны материалы по [Go](go/README.md), [базам данных](databases/README.md), [Kafka](messaging/README.md), [сетям](networking/README.md), [распределённым системам](distributed-systems/README.md), [backend patterns](backend-patterns/README.md), [System Design](system-design/README.md), [Linux](linux/README.md), [контейнерам](containers/README.md) и [observability](observability/README.md). Страницы проходят повторный технический аудит по приоритетам, поэтому глубина разделов пока различается.

## Как читать

Начните с index page нужного раздела: там указан рекомендуемый порядок. Внутри страниц гарантии спецификации отделяются от деталей реализации, а version-sensitive утверждения сопровождаются ссылками на первичные источники.

Markdown в GitHub — единственный source of truth. GitBook служит presentation layer и строит навигацию из [`SUMMARY.md`](SUMMARY.md). Исправления и дополнения можно предложить через pull request по правилам из корневого `CONTRIBUTING.md`.
