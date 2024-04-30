# Case-study оптимизации

## Актуальная проблема
В нашем проекте возникла серьёзная проблема.

Необходимо было обработать файл с данными, чуть больше ста мегабайт.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и не было понятно, закончит ли она вообще работу за какое-то разумное время.

Я решил исправить эту проблему, оптимизировав эту программу.

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы я придумал использовать такую метрику: файл должен обрабатываться не больше 30 секунд

## Гарантия корректности работы оптимизированной программы
Программа поставлялась с тестом. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.

## Feedback-Loop
Для того, чтобы иметь возможность быстро проверять гипотезы я выстроил эффективный `feedback-loop`, который позволил мне получать обратную связь по эффективности сделанных изменений за *время, которое у вас получилось*

Вот как я построил `feedback_loop`:

Выбрал для работы версию ruby-3.1.3
Сначала я распаковал архив data_large.txt.gz. Попробовал запустить программу на нем и увидел, что она не выполняется.
При запуске теста на тестовых данных размером 18 строчек программа показала время в диапазоне 0.001-0.0005 секунды.
Тогда я решил достать из data_large.txt образец данных размером 100 строк кода с помощью команды `head -n 100 data_large.txt > sample100.txt`, после чего создал файл test.rb, куда импортировал tast-1.rb, предварительно отключив в нем автопрогон тестов и изменив интерфейс метода #work, чтобы он принимал в качестве параметра файл с данными.
В новом файле импортировал библиотеку `require 'benchmark'` и замерил время выполнения для sample100.txt. Сделав аналогичные операции для 1000, 10000 и 100000 строк кода получил следующие результаты
```ruby
require_relative 'task-1.rb'

require 'benchmark'

Benchmark.bm do |x|
  x.report { work('sample100.txt') }
  x.report { work('sample1000.txt') }
  x.report { work('sample10000.txt') }
  x.report { work('sample100000.txt') }
end
```

```
       user     system      total        real
   0.002126   0.000916   0.003042 (  0.004293)
   0.043338   0.002797   0.046135 (  0.047601)
   2.070591   0.181741   2.252332 (  2.274877)
 282.355822  14.876178 297.232000 (301.957667)
```
Вычислив общее количество строк в `wc -l data_large.txt` и получив результат 3250940 можно предположить, что при росте данных в 10 раз мы получаем увеличение времени выполнения в 2^n * 10^(n-1) * 0.01 секунды где n- порядок числа строк, таким образом на 3M строках данных ожидаемый результат должен составить 64000 секунд, что является для нас неприемлемым результатом.
Следующим шагом я написал тест-кейс производительности с помощью фреймворка тестирования rspec и его расширения rspec-perfomance и добавил тест-кейс, проверяющий корректность работы данных на выборке в 100 строк
В результате мы получаем время, необходимое для feedback_loop в районе 5 секунд
```
...*.

Pending: (Failures listed here are expected and do not affect your suite's status)

  1) Perfomance works under 4s for 10000 strings of data
     # Temporarily skipped with xit
     # ./spec/performance_spec.rb:52


Finished in 4.12 seconds (files took 0.27141 seconds to load)
5 examples, 0 failures, 1 pending
```


## Вникаем в детали системы, чтобы найти главные точки роста

### RBSPY
Для того, чтобы найти "точки роста" для оптимизации я решил начать с инструмента rbspy
Устанавливаем `brew install rbspy`
Делаем наш test.rb исполняемым `chmod +x test.rb` и запускаем скрипт `sudo rbspy record --pid $PID`

Коммент: `sudo rbspy record -- bundle exec ruby test.rb` почему-то не запустилась из-за ошибок с бандлером???

Получаем слудующий вывод:
```
Time since start: 13s. Press Ctrl+C to stop.
Summary of profiling data so far:
% self  % total  name
 98.38    99.78  block in work - /Users/vocrsz/dev/rails-optimization-task1/task-1.rb:57
  1.08     1.08  split [c function] - (unknown)
  0.22   100.00  each [c function] - (unknown)
  0.22     0.65  parse_session - /Users/vocrsz/dev/rails-optimization-task1/task-1.rb:37
  0.11     0.11  parse_user - /Users/vocrsz/dev/rails-optimization-task1/task-1.rb:26
  0.00   100.00  work - /Users/vocrsz/dev/rails-optimization-task1/task-1.rb:145
  0.00   100.00  <main> - ./test.rb:14
```
Идем смотреть на 57 строчку нашего исполняемого файла. Строчка указывает на следующий код:
```ruby
  file_lines.each do |line|
    cols = line.split(',')
    users = users + [parse_user(line)] if cols[0] == 'user'
    sessions = sessions + [parse_session(line)] if cols[0] == 'session'
  end # line #57
```
Предположу, что указывая на конец блока строчка говорит, что проблемы внутри самого блока. Пока ничего не понятно, но очень интересно. Пользоваться этим я, конечно же, не буду. Переходим к следующему инструменту

### RubyProf

#### Отчет Flat
Для начала пильнем файл с небольшими данными, чтобы не умереть от старости в ожидании основного скрипта `head -n 5000 data_large.txt >> data_small.txt`
Поставим гем, обновим файл test.rb
```ruby
require_relative 'task-1.rb'
require 'ruby-prof'

profile = RubyProf::Profile.new(measure_mode: RubyProf::WALL_TIME)
GC.disable

result = profile.profile do
  work('data_small.txt')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_result/flat.txt', 'w+'))
```

В выводе видим следующее
```
Measure Mode: wall_time
Thread ID: 260
Fiber ID: 240
Total: 2.685920
Sort by: self_time

 %self      total      self      wait     child     calls  name                           location
 61.09      2.202     1.641     0.000     0.561      774   Array#select
 23.06      0.619     0.619     0.000     0.000  3696407   String#==
  4.74      0.300     0.127     0.000     0.173     5000   Array#all?
  4.30      0.172     0.116     0.000     0.057   415483   BasicObject#!=
  1.53      0.041     0.041     0.000     0.000     5974   Array#+
  1.33      2.678     0.036     0.000     2.643       10   Array#each
  0.74      0.053     0.020     0.000     0.033     8516   Array#map
```
Большую часть времени занимает метод Array#select и сравнение строк. Поищем что-то похожее в нашем скрипте
Кажется, что проблемы у нас в следующем коде (единственный #select на весь файл)
```ruby
  users.each do |user|
    attributes = user
    user_sessions = sessions.select { |session| session['user_id'] == user['id'] }
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects = users_objects + [user_object]
  end
```
Похоже на проблемы со сложностью алгоритма, кажется, что мы имеем тут сложность O(N*M), где N- количество пользователей, а M- количество сессий. Просто предположу, что возможно стоило бы воспользоваться хеш-функцией или хотя бы структурой Set, но жажда посмотреть остальные инструменты профилирования одолевает меня все сильнее

#### Отчет Graph

```ruby
printer = RubyProf::GraphHtmlPrinter.new(result)
```
Идем смотреть отчет
![ Идем смотреть отчет ](images/graph.png)

Видим, что Array#select вызывается 774 раза и занимает 59.48% общего времени выполнения
![ Array#select ](images/array#select.png)

Что же, получается проблема все там же. Идем дальше

#### Отчет Callstack

```ruby
printer = RubyProf::CallStackPrinter.new(result)
```

Говорит нам, что проблема все там же
![ Calltree ](images/calltree.png)

#### Отчет Callgrind

Ставим `brew install qcachegrind`

```ruby
printer = RubyProf::CallTreePrinter.new(result)
printer.print
```

Комментарий `printer.print(path: "ruby_prof_reports", profile: 'callgrind')` не захотел запускаться, что-то ему не понравилось в path
![ srabotal ](images/srabotal.jpg)

Так, что-то непонятное, идем разбираться
![ Calltree ](images/qcachegrind.png)

Указывает все на то же место в коде, Array#select, который мы уже собираемся поменять на Hash[]

### STACKPROF

#### STACKPROF Cli

Обновляем test.rb
```ruby
require_relative 'task-1.rb'
require 'stackprof'

GC.disable

StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
  work('data_small.txt')
end
```

Получаем вывод
```
==================================
  Mode: wall(1000)
  Samples: 636 (0.16% miss rate)
  GC: 0 (0.00%)
==================================
     TOTAL    (pct)     SAMPLES    (pct)     FRAME
       636 (100.0%)         438  (68.9%)     Object#work
       473  (74.4%)         104  (16.4%)     Array#select
        33   (5.2%)          15   (2.4%)     Date.parse
        14   (2.2%)          14   (2.2%)     String#split
        25   (3.9%)          14   (2.2%)     Array#all?
        54   (8.5%)          10   (1.6%)     Array#map
        10   (1.6%)          10   (1.6%)     Regexp#match
        75  (11.8%)           8   (1.3%)     Object#collect_stats_from_users
       632  (99.4%)           5   (0.8%)     Array#each
         4   (0.6%)           4   (0.6%)     MatchData#begin
         3   (0.5%)           3   (0.5%)     Array#sort
         3   (0.5%)           3   (0.5%)     String#gsub!
         2   (0.3%)           2   (0.3%)     String#upcase
         2   (0.3%)           1   (0.2%)     Object#parse_user
```
Показывает на тот же метод, но количество вызов отличается от 774, которые показал отчет Flat. Предположу, что зависит от интервала съема стека

#### STACKPROF speedscope

Обновляем test.rb
```ruby
require_relative 'task-1.rb'
require 'stackprof'

GC.disable

profile = StackProf.run(mode: :wall, raw: true) do
  work('data_small.txt')
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
```

Загружаем на https://www.speedscope.app/

![ Speedscope ](images/speedscope.png)

Вот тут уже видим, что Array#select вызывается 4 раза, приглядываемся повнимательнее
Я, конечно, не умею работать с flamegraph, но выглядит, как будто #work вызывается внутри Array#select
Ничего не понятно, ставлю 1 звезду из 5, не рекомендую

Вот какие проблемы удалось найти и решить

### Ваша находка №1
Все отчеты показали проблемы с Array#select
Попробуем его оптимизировать через Hash[]
Вносим исправления в код
```ruby
  sessions_by_users = sessions.group_by { |session| session['user_id'] }

  users.each do |user|
    attributes = user
    user_sessions = sessions_by_users.fetch(user['id'], [])
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects = users_objects + [user_object]
  end
```

Запускаем тесты, ловим ошибку
![ Speedscope ](images/first_optimization.png)
Комментарий: поправка, один раз сработало, но потом перестало, по-прежнему экспоненциальная зависимость


```ruby
require 'benchmark'
require_relative 'task-1.rb'

Benchmark.bm do |x|
  x.report { work('sample10000.txt') }
  x.report { work('sample100000.txt') }
end
```

Но точно стало работать быстрее
Обновляем тесты методом тыка и продолжаем искать bottlenecks
Получаем 0.45 и 19.063885 секунд на 10000 и 100000 строчек данных соответственно

### Ваша находка №2
Проще всего мне будет запустить отчет StackProf, потому что он был последним в нашем ознакомительном туре по профилировщикам. Попробуем его

Видим проблему в Object#collect_stats_from_users

```==================================
  Mode: wall(1000)
  Samples: 136 (0.00% miss rate)
  GC: 0 (0.00%)
==================================
     TOTAL    (pct)     SAMPLES    (pct)     FRAME
       136 (100.0%)          58  (42.6%)     Object#work
        27  (19.9%)          14  (10.3%)     Array#all?
        11   (8.1%)          11   (8.1%)     String#split
        48  (35.3%)          10   (7.4%)     Object#collect_stats_from_users
        22  (16.2%)           9   (6.6%)     Date.parse
         4   (2.9%)           4   (2.9%)     String#gsub!
         4   (2.9%)           4   (2.9%)     MatchData#begin
         4   (2.9%)           3   (2.2%)     Object#parse_session
```

Идем его лечить. Смотрим на метод и не понимаем, как его лечить. Будем запускать Graph, чтобы посмотреть стек вызовов
25% времени занимает метод Array#all?. Ищем его
Видим вызов в 2 местах, но помня о предыдущем отчете, предполагаем, что проблемный метод находится внутри метода #collect_stats_from_users, который принимает блок

```ruby
# Всегда использовал только Chrome?
collect_stats_from_users(report, users_objects) do |user|
  { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ } }
end
```
С помощью такой-то матери, #match? (оказывается надо вопросительный знак писать) и #uniq переписываем метод

```ruby
  collect_stats_from_users(report, users_objects) do |user|
    user_browsers = user.sessions.map{|s| s['browser']}.uniq
    user_always_use_chrome = user_browsers.uniq.size == 1 && user_browsers.first.upcase.match?(/CHROME/)

    { 'alwaysUsedChrome' => user_always_use_chrome }
  end
```

Попутно понимаем, что в коде, очевидно, ошибка и если массив пустой- пользователь будет помечен как всегда использующий Chrome.
![ Other Story ](images/other_story.jpeg)

Попутно видим, что тесты упали, говорят, что регрессия линейная. Фиксим и опять же методом тыка обновлям данные по тестам
Метод тыка не показал прироста на выборках данных 100, 1000 и 10_000, зато теперь проходит тест на линеечку

### Ваша находка №3
Снова запускаем отчет Graph (по пути наименьшего сопротивления, он же у нас уже работает) и снова видим метод Array#all? 25%, на этот раз при подсчете количества браузеров
```ruby
# Подсчёт количества уникальных браузеров
uniqueBrowsers = []
sessions.each do |session|
  browser = session['browser']
  uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
end
```
Пробуем
```ruby
# Подсчёт количества уникальных браузеров
uniqueBrowsers = sessions.map { |session| session['browser'] }.uniq
```
Казалось бы, должно работать быстрее, но падает тест на линеечку. Придется замерять вручную, неужели "оптимальный" код неоптимальный
```ruby
# Подсчёт количества уникальных браузеров
uniqueBrowsers = []
uniqueBrowsers1 = []
Benchmark.bm do |x|
  x.report { uniqueBrowsers1 = sessions.map { |session| session['browser'] }.uniq }
  x.report {
    sessions.each do |session|
      browser = session['browser']
      uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
    end
  }
end
```
Получаем результат
```
    user     system      total        real
0.000047   0.000012   0.000059 (  0.000042)
0.000279   0.000008   0.000287 (  0.000285)
```
Хм, видим, что наш метод должен работает быстрее
Зато метод тыка показал, что цифры на исполнение кода на заданных тестовых данных стали чуть быстрее
Спишем на проблему библиотеки и пойдем искать дальше

### Ваша находка №4
Снова вызываем Graph отчет
Повторяем шаги и видим проблему опять в ~~рассадние заразы~~ #collect_stats_from_users, строка №40, а именно Array#each и сложение массивов. Находим в отчете номер строчки, видим 55, что у нас там?
```ruby
file_lines.each do |line|
  cols = line.split(',')
  users = users + [parse_user(line)] if cols[0] == 'user'
  sessions = sessions + [parse_session(line)] if cols[0] == 'session'
end
```
Кажется, это неоптимальный сбор данных в массив. Рефакторим
```ruby
file_lines.each do |line|
  cols = line.split(',')

  case cols[0]
  when 'user'
    users = users << parse_user(line)
  when 'session'
    sessions = sessions << parse_session(line)
  end
end
```
Все еще экспонента, снова запускаем отчет и видим Date.parse
Присматриваемся и понимаем, что мы парсим дату, сортируем по ней, а потом приводим к тому же формату
```ruby
  collect_stats_from_users(report, users_objects) do |user|
    # it is true
    puts user.sessions.first['date'].to_s == Date.parse(user.sessions.first['date']).iso8601.to_s
    { 'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
  end
```

Рефакторим
```ruby
# Даты сессий через запятую в обратном порядке в формате iso8601
collect_stats_from_users(report, users_objects) do |user|
  { 'dates' => user.sessions.map{|s| s['date']}.sort.reverse }
end
```

Все еще экспонента, но на 10_000 данных работает в 3 раза быстрее. Остальные тесты решил не обновлять, т.к. интересует только самый большой. Коммитим

### Ваша находка №5
Ох, как я с тобой намаюсь
![ Other Story ](images/attempt5.jpeg)

Повторяем цикл и находим Array#each, который вызывает Array#map. Смотрим
Видим дублирующий поиск уникальных браузеров
```ruby
uniqueBrowsers = sessions.map { |session| session['browser'] }.uniq

report['uniqueBrowsersCount'] = uniqueBrowsers.count

report['totalSessions'] = sessions.count

report['allBrowsers'] =
  sessions
    .map { |s| s['browser'] }
    .map { |b| b.upcase }
    .sort
    .uniq
    .join(',')
```
Рефакторим
Мимо
Повторяем
Блин, ну конечно, #collect_stats_from_users бегает по пользователям и каждый раз бегает еще по куче массивов. Объединяем все вызовы в 1, проверяем, успех, линеечка
```ruby
collect_stats_from_users(report, users_objects) do |user|
  # Собираем количество сессий по пользователям
  sessionsCount = user.sessions.count

  # Собираем количество времени по пользователям
  totalTime = user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.'

  # Выбираем самую длинную сессию пользователя
  longestSession = user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.'

  # Браузеры пользователя через запятую
  browsers = user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ')

  # Хоть раз использовал IE?
  usedIE = user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ }

  # Всегда использовал только Chrome?
  user_browsers = user.sessions.map{|s| s['browser']}.uniq
  user_always_use_chrome = user_browsers.uniq.size == 1 && user_browsers.first.upcase.match?(/CHROME/)

  alwaysUsedChrome = user_always_use_chrome

  # Даты сессий через запятую в обратном порядке в формате iso8601
  dates = user.sessions.map{|s| s['date']}.sort.reverse

  {
    'sessionsCount'    => sessionsCount,
    'totalTime'        => totalTime,
    'longestSession'   => longestSession,
    'browsers'         => browsers,
    'usedIE'           => usedIE,
    'alwaysUsedChrome' => alwaysUsedChrome,
    'dates'            => dates,
  }
end
```

Добавим тесткейс для 100_000, показывает 2 секунды
При линейной зависимости можем ожидать примерно 90 секунд на 3_500_000 строчек, близко к бюджету, но пока не то

### Ваша находка №5
Прогоним еще раз Graph отчет
Находим несколько результатов, но особенно интересует String#split c 14%. Видим, что половину всех вызовов занимает 54 строчка
```ruby
file_lines.each do |line|
  cols = line.split(',')

  case cols[0]
  when 'user'
    users = users << parse_user(line)
  when 'session'
    sessions = sessions << parse_session(line)
  end
end
```
Похоже, что файл в формате CSV, попробуем использовать стандартную библиотеку
Так же видим, что parse_user и parse_session принимают строку, которую потом преобразовывают в массив, а из csv мы итак получаем массив. Починим
```ruby
def parse_user(fields)
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

CSV.foreach(filename, headers: false) do |row|
  case row[0]
  when 'user'
    users = users << parse_user(row)
  when 'session'
    sessions = sessions << parse_session(row)
  end
end
```
Большого прироста не получаем
Но работает, идем дальше
Повторяем запуск профилировщика
Видим, что теперь 30% от всего времени выполнения отжирает csv
Попробуем переписать

```ruby
File.readlines(filename, chomp: true).each do |line|
  splitted_line = line.split(',')

  case splitted_line[0]
  when 'user'
    users = users << parse_user(splitted_line)
  when 'session'
    sessions = sessions << parse_session(splitted_line)
  end
end
```
2 секунды против 2.8 на 100_000 данных. Вроде успех
Повторяем, видим, что Array#map съедает много времени внутри #collect_user_data
Видим двойной проход по массиву в нескольких местах, исправляем, получаем 1.7 секунды
```ruby
# totalTime = user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.'
totalTime = user.sessions.sum_by {|s| s['time'].to_i}.map {|t| t.}.to_s + ' min.'
```

Повторяем запуск профилировщика, видим, что #parse_session занимает 9% и является самым жирным куском кода. Рефакторим, получаем небольшой прирост к производительности
```ruby
def parse_session(fields)
  type, user_id, session_id, browser, time, date = *fields
  parsed_result = {
    'user_id' => user_id,
    'session_id' => session_id,
    'browser' => browser,
    'time' => time,
    'date' => date,
  }
end
```

Повторяем запуск профилировщика, видим, что #upcase при каждом проходе по именам браузеров и занимает 3% в долгом методе Array#map. Исправляем, вынося метод в #parse_session, проверяем, прироста не получаем на 100_000

Повторяем, видим Array#map, вызывается много раз, особенно часто бегает по сессиям и достает браузеры, занимает 10% и вызывается в долгом методе Array#each. Выносим браузеры в отдельную переменную

Видим в отчете, что для сессии много раз вызывается session['time'].to_i, заполняем сразу же Integer значение при билде сессии (2%)

4 раза вызывается Array#each и отъедает большую часть времени.
Отрефакторили сборку users_objects, убрали из объекта пользователя сессию, стали делать сборку users_objects непосредственно в момент парсинга файла, убрав лишний проход по массиву. В результате получили красивую линеечку в тестах (100 строк- 2мс, 1000 строк- 10мс, 10_000 строк- 100мс, 100_000 строк- 1с)

Вижу по отчету, что можно сэкономить 1.5% на замене класса User на хэш

Стоило сделать это раньше, но, пожалуй, добавлю прогресс-бар

## Результаты
В результате проделанной оптимизации наконец удалось обработать файл с данными.
Удалось улучшить метрику системы с *того, что у вас было в начале, до того, что получилось в конце* и уложиться в заданный бюджет.

*Какими ещё результами можете поделиться*

## Защита от регрессии производительности
Для защиты от потери достигнутого прогресса при дальнейших изменениях программы *о performance-тестах, которые вы написали*


Сложно заставить себя пользоваться другим инструментов
Оказалось, что каждый раз смотрел куда-то не туда
Надо было настроить нормальную генерацию graph отчетов, чтобы после каждой итерации не приходилось менять номер отчета в браузере и в файле
