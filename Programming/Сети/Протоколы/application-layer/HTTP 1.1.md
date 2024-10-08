---
создал заметку: 2024-07-23
tags:
  - network
  - protocols
  - "#applicationlayer"
---
### Описание

**HTTP (HyperText Transfer Protocol)** — это протокол прикладного уровня, используемый для передачи данных в Интернете. Он лежит в основе World Wide Web и обеспечивает передачу гипертекста, включая HTML, изображения, видео и другие типы данных. Работает HTTP с помощью протоколов [TCP](../transport-layer/TCP.md), [IP](../internet-layer/IP.md) и использует их, чтобы передавать данные.

В обмене информацией по HTTP-протоколу принимают участие клиент и сервер. Происходит это по следующей схеме: 

1. Клиент запрашивает у сервера некоторый ресурс.
2. Сервер обрабатывает запрос и возвращает клиенту ресурс, который был запрошен.

![](https://i.imgur.com/sdIvgY8.png)

#### HTTP-сообщения: запросы и ответы

Данные между клиентом и сервером в рамках работы протокола передаются с помощью HTTP-сообщений. Они бывают двух видов:

- **Запросы (HTTP Requests)** — сообщения, которые отправляются клиентом на сервер, чтобы вызвать выполнение некоторых действий. Зачастую для получения доступа к определенному ресурсу. Основой запроса является HTTP-заголовок.
- **Ответы (HTTP Responses)** — сообщения, которые сервер отправляет _в ответ_ на клиентский запрос.

Само по себе сообщение представляет собой информацию в текстовом виде, записанную в несколько строчек.

В целом, как запросы HTTP, так и ответы имеют следующую структуру:
![](https://i.imgur.com/hQUlsFg.png)

1. _Стартовая строка (start line)_ — используется для описания версии используемого протокола и другой информации — вроде запрашиваемого ресурса или кода ответа. Как можно понять из названия, ее содержимое занимает ровно одну строчку.
	![](https://i.imgur.com/IMYfv34.png)
1. _HTTP-заголовки (HTTP Headers)_ — несколько строчек текста в определенном формате, которые либо уточняют запрос, либо описывают содержимое _тела_ сообщения.
2. *Пустая строка*, которая сообщает, что все метаданные для конкретного запроса или ответа были отправлены.
3. Опциональное _тело сообщения_, которое содержит данные, связанные с запросом, либо документ (например HTML-страницу), передаваемый в  ответе.

**HTTP-ответ** является сообщением, которое сервер отправляет клиенту _в ответ_ на его запрос. Его структура равна структуре HTTP-запроса: стартовая строка, заголовки и тело.
![](https://i.imgur.com/k2eQGEJ.png)
#### Методы HTTP Запросов

1. **GET** - запрашивает представление ресурса.
2. **POST** - отправляет данные на сервер для создания или обновления ресурса.
3. **PUT** - обновляет или создает ресурс по указанному URI.
4. **DELETE** - удаляет указанный ресурс.
5. **HEAD** - запрашивает заголовки ответа, аналогично GET, но без тела.
6. **OPTIONS** - запрашивает поддерживаемые методы для ресурса.
7. **PATCH** - вносит частичные изменения в ресурс.
#### Статусы HTTP Ответов

1. **1xx Информационные**: Указывает, что запрос принят и продолжается обработка.
2. **2xx Успех**: Запрос успешно выполнен.
	- **200 OK**: Запрос успешен.
3. **3xx Перенаправление**: Требуется дополнительное действие для завершения.
	- **301 Moved Permanently**: Ресурс перемещен на новый URI.
4. **4xx Ошибки клиента**: Ошибка на стороне клиента.
	- **404 Not Found**: Ресурс не найден.
5. **5xx Ошибки сервера**: Ошибка на стороне сервера.
	- **500 Internal Server Error**: Общая ошибка сервера.

### Краткое Содержание

**HTTP (HyperText Transfer Protocol)** — это протокол передачи данных в Интернете, работающий поверх *TCP/IP*. Он используется для обмена информацией между клиентами и серверами по принципу запрос-ответ. Поддерживает различные методы запросов (*GET, POST, PUT* и другие). Сообщения HTTP состоят из *стартовой строки, заголовков и тела*. Протокол поддерживает кеширование и может быть безопасным через HTTPS. ^c8acf6