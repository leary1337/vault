# Backend Knowledge Base

Русскоязычная база знаний для Middle+/Senior Go backend-разработчиков. Markdown в этом репозитории — единственный source of truth; GitBook используется только для публикации и навигации.

## Публичная версия

URL GitBook будет добавлен после настройки Git Sync владельцем репозитория.

## Структура

- [`docs/`](docs/) — публикуемый контент;
- [`docs/SUMMARY.md`](docs/SUMMARY.md) — навигация GitBook;
- [`maintenance/`](maintenance/) — аудит, журнал миграции и backlog;
- [`.gitbook.yaml`](.gitbook.yaml) — корень и структура GitBook.

## Локальная работа

Специальная сборка не нужна: откройте Markdown-файлы в любом редакторе. Перед pull request запустите:

```powershell
pwsh scripts/check-docs.ps1
```

Правила оформления и проверки описаны в [`CONTRIBUTING.md`](CONTRIBUTING.md).

## GitBook Git Sync

GitBook читает документацию из `docs/`. Главная страница — `docs/README.md`, порядок страниц — `docs/SUMMARY.md`. Изменения следует вносить в GitHub; после подключения Git Sync они публикуются из выбранной ветки.

## Лицензия

Лицензия пока не определена. До появления `LICENSE` стандартные права на повторное использование контента не предоставляются.
