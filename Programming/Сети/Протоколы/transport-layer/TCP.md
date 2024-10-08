---
создал заметку: 2024-07-23
tags:
  - network
  - protocols
  - "#transportlayer"
---
### Описание

**Transmission Control Protocol (TCP)** — это протокол транспортного уровня в стеке [TCP/IP](../../Модель%20TCP%20IP.md), который обеспечивает надежную и упорядоченную передачу данных между устройствами. TCP использует [сокеты](../../Интерфейсы/Сокет.md) для установления соединений и передачи данных между хостами, абстрагируя программистов от деталей сетевого взаимодействия.

**Сервис TCP**
- **Надежная передача потока байтов**: TCP гарантирует доставку данных, их целостность и порядок.

#### Гарантии TCP:
- **Доставка данных**: TCP гарантирует, что все данные будут доставлены, даже если потребуется повторная передача.
- **Сохранение порядка**: Данные передаются в том порядке, в котором они были отправлены.

#### Поток байт

![](https://i.imgur.com/10FOsI9.png)

- TCP принимает поток байтов от приложения, разбивает его на сегменты и передает по сети. Получатель собирает сегменты обратно в исходный поток.

#### Формат заголовка TCP

![](https://i.imgur.com/mmUFBuG.png)
- **Порт отправителя и порт получателя**: указывают отправителя и получателя (16 бит каждый).
- **Порядковый номер**: номер первого байта в сегменте, используемый для восстановления порядка данных (32 бита).
- **Номер подтверждения**: номер следующего ожидаемого байта, используемый для подтверждения получения данных (32 бита).
- **Длина заголовка**: указывает длину заголовка TCP в 32-битных словах (4 бита).
- **Флаги управления**: включает важные флаги:
    - **URG**: указатель срочности активен.
    - **ACK**: номер подтверждения активен.
    - **PSH**: передача данных немедленно.
    - **RST**: сброс соединения.
    - **SYN**: инициализация соединения.
    - **FIN**: завершение соединения.
- **Размер окна**: количество байтов, которые отправитель готов принять (16 бит).
	![](https://i.imgur.com/hjwr7Lh.gif)
- **Контрольная сумма**: проверка целостности заголовка и данных (16 бит).
- **Указатель на срочные данные**: используется, если флаг URG установлен (16 бит).
- **Параметры**: дополнительные опции, такие как MSS (Maximum Segment Size), SACK (Selective Acknowledgment), масштаб окна.

#### Управление перегрузкой

TCP включает механизмы для управления перегрузкой сети:
- **Slow Start**: начальная передача данных с постепенным увеличением скорости.
- **Congestion Avoidance**: контроль скорости передачи данных для предотвращения перегрузки.
- **Fast Retransmit**: быстрая повторная передача данных при обнаружении потери пакетов.
- **Fast Recovery**: ускоренное восстановление после перегрузки.

#### Гарантия доставки

![](https://i.imgur.com/03Z1oKL.png)
- TCP использует кумулятивное подтверждение, подтверждая получение всех байтов до указанного номера.
- **Выборочное подтверждение (SACK)**: подтверждает только определенные диапазоны байтов, что эффективно при потере пакетов.

#### Порядок следования сообщений
- TCP поддерживает нумерацию сегментов для обеспечения правильного порядка данных. Дублированные данные игнорируются. ![](https://i.imgur.com/v9K2tQB.png)

#### Соединение TCP
- Установка соединения начинается с трехстороннего рукопожатия (SYN, SYN-ACK, ACK), где устанавливаются параметры соединения. ![](https://i.imgur.com/Pv4WCYk.png)
- Разрыв соединения может быть односторонним или двусторонним, с использованием FIN или RST для завершения передачи данных.

![](https://i.imgur.com/Imdfh5W.gif)
### Краткое содержание

**TCP (Transmission Control Protocol)** — это транспортный протокол, обеспечивающий надежную и упорядоченную передачу данных между хостами. TCP использует механизмы управления перегрузкой и поддерживает установку и разрыв соединений, гарантируя доставку данных. ^e0a326