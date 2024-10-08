---
создал заметку: 2024-07-24
tags:
  - network
  - protocols
  - applicationlayer
---
### Описание

**HTTPS (HyperText Transfer Protocol Secure)** — это защищённая версия [HTTP](HTTP%201.1.md), обеспечивающая безопасную передачу данных между клиентом и сервером. HTTPS использует [TLS SSL](TLS%20SSL.md) для шифрования данных. Основная цель HTTPS — защитить данные от перехвата и модификации.
#### Как работает HTTPS?

1. **Установка соединения:**
    - При использовании HTTP клиент устанавливает соединение с сервером через TCP и отправляет запрос в текстовом формате, например, GET-запрос для получения веб-страницы.
    - В HTTPS соединение сначала устанавливается через TCP, а затем через TLS. Сервер и клиент обмениваются сообщениями для установления защищенного соединения.
2. **Порты:**
    - HTTP обычно работает на порту 80, тогда как HTTPS использует порт 443.
3. **Процесс установления защищенного соединения:**
    - Клиент отправляет запрос на установление TLS-сессии, а сервер отвечает, устанавливая защищённое соединение. После этого передача данных происходит уже через защищённое соединение.

#### Стандарты и спецификации

- **RFC 2818 (2000 год):** Описывает использование HTTP поверх TLS. Указывает, как устанавливать защищённое соединение без изменений в сам протокол HTTP.
- **Другие методы обеспечения безопасности:**
    - **RFC 2817 (2000 год):** Описывает механизм перехода с HTTP на HTTPS на стандартном порту 80 с использованием заголовка Upgrade.
    - **RFC 2660 (1999 год):** Описывает протокол S-HTTP, который не получил широкого распространения.

#### Преимущества HTTPS

- **Шифрование данных:** Все данные между клиентом и сервером шифруются, что защищает их от перехвата.
- **Аутентификация:** Подтверждение подлинности сервера, с которым общается клиент.
- **Целостность данных:** Защита от изменения передаваемых данных.
### Краткое содержание

**HTTPS** — это не отдельный протокол, а скорее вариант использования *HTTP* с дополнительным уровнем безопасности через *TLS*. Это стандарт для передачи веб-страниц, обеспечивающий защиту данных пользователей. ^848893
