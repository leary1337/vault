---
создал заметку: 2024-07-24
tags:
  - golang
---
### Описание

**Go runtime (рантайм)** — это набор инструментов и библиотек, которые поддерживают выполнение Go-программ. Runtime управляет такими задачами, как работа с памятью, запуск и планирование горутин, обработка вызовов системы и многое другое.
#### Основные компоненты рантайма

1. **Сборщик мусора (GC)**: автоматическое управление памятью, освобождение неиспользуемой памяти.
2. **Планировщик**: управление выполнением горутин и распределение их на системные потоки.
3. **Реализация примитивов синхронизации**: мьютексы, каналы и другие средства для безопасного взаимодействия между горутинами.
4. **Обработка паник**: механизм для обработки критических ошибок и восстановления программы.
#### Функции рантайма

1. `runtime.Gosched()`:
	Принудительно передает управление другой горутине. Эта функция приостанавливает текущую горутину, позволяя планировщику выполнить другие горутины.

2. `runtime.Goexit()`:
	Завершает выполнение текущей горутины без паники. Другие горутины продолжают выполняться. Эта функция завершает горутину, вызывая все отложенные вызовы (defer), но не завершает программу.

3. `runtime.NumGoroutine()`:
	Возвращает количество активных горутин. Полезно для мониторинга и отладки программы.

4. `runtime.GC()`:
	Принудительно запускает сборщик мусора. Обычно не требуется вызывать эту функцию вручную, так как Go автоматически управляет сбором мусора. Однако может быть полезно для тестирования и отладки.

5. `runtime.ReadMemStats(m *runtime.MemStats)`:
	Заполняет структуру `MemStats` статистикой использования памяти. Это позволяет получить информацию о текущем состоянии памяти программы, включая объем выделенной памяти, количество сборок мусора и т.д.

6. `runtime.NumCPU()`:
	Возвращает количество доступных процессоров. Это полезно для настройки параллелизма в программе.

7. `runtime.LockOSThread()`:
	Закрепляет текущую горутину за текущим системным потоком (OS thread). Это может быть необходимо, если горутина выполняет операции, которые должны быть связаны с определенным потоком, например, вызовы сторонних библиотек.

8. `runtime.UnlockOSThread()`:
	Разблокирует текущий поток, позволяя другим горутинам использовать его.

9. `runtime.Version()`:
	Возвращает строку с версией Go, используемой для компиляции программы.

10. `runtime.GOOS` и `runtime.GOARCH`:
	Константы, представляющие операционную систему и архитектуру процессора, для которых была скомпилирована программа.
### Краткое содержание

**Рантайм Go** играет ключевую роль в управлении жизненным циклом программы и взаимодействии с операционной системой. Он включает в себя *сборщик мусора*, *планировщик*, *механизмы обработки паник* и другие компоненты, обеспечивающие надежную и эффективную работу программ на Go. Пакет `runtime` предоставляет программистам доступ к функциям и данным, связанным с рантаймом, что позволяет тонко настроить поведение приложений. ^49addc

