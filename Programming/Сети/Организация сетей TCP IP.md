---
создал заметку: 2024-07-23
tags:
  - network
  - tcp/ip
---
### Описание

#### 1) Уровень сетевых интерфейсов

**Задача:** Подключение к сетевым технологиям, таким как Wi-Fi и Ethernet.

**Физическая (аппаратная) адресация:**

- **MAC (Media Access Control) адреса:**
    - Используются для уникальной идентификации устройств в сети.
    - Регламентируются стандартом IEEE 802.
    - Каждый сетевой адаптер Wi-Fi и Ethernet имеет встроенный MAC-адрес, который должен быть уникальным в пределах одной сети.

**Формат MAC адреса:**
- Длина: 6 байт (48 бит).
- Форма записи: шесть шестнадцатеричных чисел:
    - Примеры: `1C-75-08-D2-49-45` (формат IEEE) и `1C:75:08:D2:49:45` (формат EITF).

**Особенности использования MAC-адресов:**
- Уникальность: В пределах одной локальной сети (LAN) MAC-адреса должны быть уникальными, чтобы избежать конфликтов.
- Неизменяемость: MAC-адрес обычно записан в аппаратное обеспечение устройства и не меняется.

#### 2) Уровень интернет

**Задача:** Определение маршрута для передачи данных между сетями через маршрутизаторы, даже в случае отказа некоторых из них.

**Функции:**
- Объединение сетей, построенных по разным технологиям (например, Wi-Fi и Ethernet).
- Использование IP-адресов для глобальной адресации.

#### 3) Транспортный уровень

**Задача:** Обеспечение надежной передачи данных между процессами на различных хостах.

- **Адресация на транспортном уровне:**
    - Порты: Числа от 1 до 65535, которые служат идентификаторами процессов или приложений на хосте.
    - Пример: `192.168.1.100:80`, где `80` - это порт, обычно используемый для HTTP.

- **Надежность:**
    - Транспортный уровень может обеспечивать надежность передачи данных, даже если базовая сеть не предоставляет такой гарантии.
    - Методы: Подтверждение получения, повторная отправка данных, гарантия порядка следования сообщений (нумерация).

**Протоколы транспортного уровня:**
- **[TCP](Протоколы/transport-layer/TCP.md)** (Transmission Control Protocol) - обеспечивает надежную и упорядоченную передачу данных.
- **[UDP](Протоколы/transport-layer/UDP.md)** (User Datagram Protocol) - обеспечивает более быструю, но менее надежную передачу.

#### 4) Прикладной уровень

**Задача:** Обеспечение взаимодействия между сетевыми приложениями, используя прикладные протоколы.

- **Изоляция от сетевого оборудования:** Прикладной уровень взаимодействует с транспортным, который в свою очередь взаимодействует с сетевым оборудованием.

**Протоколы прикладного уровня:**

- **[HTTP 1.1](Протоколы/application-layer/HTTP%201.1.md)** (Hypertext Transfer Protocol) - передача гипертекста и Web-страниц.
- **[HTTPS](Протоколы/application-layer/HTTPS.md)** (Hypertext Transfer Protocol Secure) - безопасная передача данных с использованием шифрования.
- **[DNS](Протоколы/application-layer/DNS.md)** (Domain Name System) - система, определяющая IP-адреса по доменным именам.
- **[SMTP](SMTP)** (Simple Mail Transfer Protocol) - протокол для передачи электронной почты.

### Краткое содержание

> [!NOTE]
> Модель TCP/IP описывает структуру и взаимодействие сетей, состоящих из четырех уровней:
> 1. **Сетевых интерфейсов**: обеспечивает подключение к различным технологиям (Wi-Fi, Ethernet) с помощью уникальных MAC-адресов.
> 2. **Интернет**: отвечает за маршрутизацию данных между сетями, используя глобальные IP-адреса.
> 3. **Транспортный**: обеспечивает надежную передачу данных между процессами на хостах через протоколы TCP и UDP, используя порты.
> 4. **Прикладной**: взаимодействие сетевых приложений с помощью таких протоколов, как HTTP, HTTPS, DNS и SMTP.
> 
> Модель позволяет различным сетевым устройствам и программному обеспечению различных производителей взаимодействовать эффективно, обеспечивая стандартизацию и надежность.

^e74523
