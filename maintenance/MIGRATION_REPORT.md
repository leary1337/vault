# Migration report

## Статус

Batch 1 завершён. 50 содержательных страниц перенесены в `docs/` с URL-friendly путями; три index pages пересобраны без Obsidian transclusions. После проверки полноты mapping и ссылок legacy-каталоги `Programming/` и `Templates/` удалены. Старые версии остаются восстановимыми из Git history.

## Решения

- GitBook root: `docs/`; навигация: `docs/SUMMARY.md`.
- Старые block IDs удалены после замены summary transclusions явными ссылками.
- Исходная дата сохранена как `created`; `updated` ставится только после технической проверки.
- Локальных assets в исходном Vault не было. Внешние изображения пока учтены как migration debt; они не копируются автоматически.
- Большая Kafka-заметка сохранена вне публичной навигации как `legacy-overview.md` до тематического rewrite.
- Пустая Docker-заметка сохранена вне публичной навигации как свидетельство rewrite decision.
- Obsidian templates не являются частью Backend Knowledge Base и удалены вместе с legacy tree после проверки.

## Перемещено

- `Programming/Go/**` → `docs/go/{language,data-structures,concurrency,runtime,performance}/**`.
- `Programming/База данных/**` → `docs/databases/**`.
- `Programming/Брокеры сообщений/Kafka.md` → `docs/messaging/kafka/legacy-overview.md` как непубличный source material.
- `Programming/Сети/**` → `docs/networking/{fundamentals,transport,application}/**`.
- `Programming/System Design/**` → `docs/system-design/fundamentals/**`.
- Пустая Docker-заметка → `docs/containers/docker/legacy-note.md` как непубличное migration record.

Точное постраничное отображение зафиксировано в [`VAULT_AUDIT.md`](VAULT_AUDIT.md).

## Удалено

- `Programming/` после успешной проверки 53 исходных Markdown-файлов против 50 содержательных target pages и трёх пересобранных index pages.
- `Templates/`: четыре файла с Obsidian Templater syntax не относились к публичной backend-базе.

## Проверки Batch 1

- 70 Markdown-файлов в `docs/`.
- 67 уникальных пунктов навигации в `docs/SUMMARY.md`.
- Нет missing local targets, Obsidian wiki-links и block IDs.
- Локальных изображений в исходном репозитории не было; внешний image debt записан в backlog и audit.

## Источник конфигурации

Синтаксис `.gitbook.yaml` проверен по [официальной документации GitBook](https://gitbook.com/docs/getting-started/git-sync/content-configuration): пути `structure` считаются относительно `root`.

## Mapping

Полная таблица source → target находится в `VAULT_AUDIT.md`; последующие технические объединения и удаления будут добавляться после каждого batch.
