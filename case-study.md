# Case-study оптимизации

## Актуальная проблема
В нашем проекте возникла серьёзная проблема:

Необходимо было обработать файл с данными, чуть больше ста мегабайт.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и не было понятно, закончит ли она вообще работу за какое-то разумное время.

Я решил исправить эту проблему, оптимизировав эту программу.

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы я написал простейший бенчмарк, последовательно тестирующий время выполнения программы с разным количеством строк:

```ruby

require 'benchmark'

require 'ruby-prof'
require_relative 'task-1'

File.write('result.json', '')

def prepare_data_file(user_count = 1)
  File.write('data.txt',
             'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
' * user_count)
end

user_counts = [1, 5, 10, 50, 100, 500]
user_counts.each do |count|
  prepare_data_file(count)
  user_time = Benchmark.realtime do
    work
  end
  puts "finished #{count} user(s) in #{user_time}"
end
```

Первый прогон бенчмарка дал результаты, от которых можно было отталкиваться:

```shell

finished 1 user(s) in 0.000670084999910614
finished 5 user(s) in 0.00102659899948776
finished 10 user(s) in 0.0035505199994076975
finished 50 user(s) in 0.08020978599961381
finished 100 user(s) in 0.33428546499999356
finished 500 user(s) in 8.259295051000663
```
Видно, что время выполнения растет нелинейно, сложность алгоритма O(N^N). С этим нужно было что-то делать.

## Гарантия корректности работы оптимизированной программы
Программа поставлялась с тестом. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.
Этот тест запускался по мере необходимости после внесения изменений в программу и перед бенчмарками.

## Feedback-Loop
Для того, чтобы иметь возможность быстро проверять гипотезы я выстроил удобный `feedback-loop`, который позволил мне получать обратную связь по эффективности сделанных изменений.
`feedback-loop` рос и модифицировался по мене необходимости. Сначала это был один тест с последовательным прогоном нескольких записей с (`1, 5, 10, 50, 100, 500`) и выводом времени выполнения
Затем к тесту добавились отчеты `ruby-prof` и `stackprof`. Каждый из них помогал в свое время, однако основным стал `Flat` отчет `ruby-prof` с выводом в `STDOUT`. 
Это позволяло получить обратную связь оперативнее сразу в консоли.


## Вникаем в детали системы, чтобы найти главные точки роста

При замене строки в task-1.rb:47 на file_lines = File.read('data_large.txt').split("\n") программа виснет, не подавая признаков жизни. top показывает потребление CPU при этом в диапазоне 99-100%, потребление памяти стабильно в районе 1,9-2%.
Подключился к подвешенному процессу через rbspy, увидел такую картину:

```bash
Time since start: 18s. Press Ctrl+C to stop.
Summary of profiling data so far:
% self  % total  name
 99.72    99.94  block in work - task-1.rb
  0.17     0.17  parse_session - task-1.rb
  0.06   100.00  <c function> - unknown
  0.06     0.06  parse_user - task-1.rb
  0.00   100.00  work - task-1.rb
  0.00   100.00  with_info_handler - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  with_info_handler - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  time_it - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  test_result - task-1.rb
  0.00   100.00  run_one_method - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  on_signal - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  capture_exceptions - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  block in run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  block in run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  block in autorun - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  block in __run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  block (3 levels) in run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  block (2 levels) in run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
```

Большую часть процессорного времени на себя берет метод work. К сожалению, он достаточно массивный, для анализа требуется разбить его на более мелкие методы. 
Сперва в отдельный метод `file_lines_iteration` был выведен блок 
```bash
file_lines.each do |line|
    cols = line.split(',')
    users = users + [parse_user(line)] if cols[0] == 'user'
    sessions = sessions + [parse_session(line)] if cols[0] == 'session'
  end
```
После прогона rbspy видим, что теперь file_lines_iteration возглавляет список:

```bash
Time since start: 9s. Press Ctrl+C to stop.
Summary of profiling data so far:
% self  % total  name
 99.34   100.00  block in file_lines_iteration - task-1.rb
  0.33   100.00  <c function> - unknown
  0.22     0.22  parse_user - task-1.rb
  0.11     0.11  parse_session - task-1.rb
  0.00   100.00  work - task-1.rb
  0.00   100.00  with_info_handler - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  with_info_handler - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  time_it - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  test_result - task-1.rb
  0.00   100.00  run_one_method - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  on_signal - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  file_lines_iteration - task-1.rb
  0.00   100.00  capture_exceptions - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  block in run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  block in run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  block in autorun - /
```
Из метода `file_lines_iteration` выделил содержимое в отдельный метод `process_line`, прогнал тест, посмотрел отчет `ruby-prof#callgrid`, ожидаемо увидел, что теперь `process_line` вызывается чаще всего.
Разбил метод на несколько таким образом:

```ruby
def parse_user_and_add_to_user(cols, line, users)
  users = users + [parse_user(line)] if cols[0] == 'user'
end

def parse_session_and_add_to_sessions(cols, line, sessions)
  sessions = sessions + [parse_session(line)] if cols[0] == 'session'
end

def work
  file_lines = File.read('data.txt').split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    parse_user_and_add_to_user(cols, line, users)
    parse_session_and_add_to_sessions(cols, line, sessions)
  end
# <------->
end
```
После изменения упал тест. Изменения откатил.
Сконцентрировался на `collect_stats_from_single_user`:


Решил больше не пытаться разобраться в проблеме "на глазок". 

Для того, чтобы найти "точки роста" для оптимизации я в первую очередь сформировал отчет `callgrid`, который показал, что бОльшая часть времени уходит на метод `Array.each`, вызываетмый


Вот какие проблемы удалось найти и решить

### Ваша находка №1
- какой отчёт показал главную точку роста
- как вы решили её оптимизировать
- как изменилась метрика
- как изменился отчёт профилировщика - исправленная проблема перестала быть главной точкой роста?

### Ваша находка №2
- какой отчёт показал главную точку роста
- как вы решили её оптимизировать
- как изменилась метрика
- как изменился отчёт профилировщика - исправленная проблема перестала быть главной точкой роста?

### Ваша находка №X
- какой отчёт показал главную точку роста
- как вы решили её оптимизировать
- как изменилась метрика
- как изменился отчёт профилировщика - исправленная проблема перестала быть главной точкой роста?

## Результаты

В результате проделанной оптимизации наконец удалось обработать файл с данными.
Удалось улучшить метрику системы с *того, что у вас было в начале, до того, что получилось в конце* и уложиться в заданный бюджет.

*Какими ещё результами можете поделиться*

####Результаты теста
|                           |                        |                                  | 
|---------------------------|------------------------|----------------------------------| 
| Количество юзеров в файле | до оптимизаций, с      | После оптимизаций, с             | 
| 1                         | 0.00044304000039119273 |        не измерялось             | 
| 5                         | 0.0032413640001323074  |        не измерялось             | 
| 10                        | 0.0089597149999463     |  0.0005151439982000738           | 
| 50                        | 0.20008935000078054    |  0.000861273001646623            | 
| 100                       | 0.8346927900001901     |  0.001767244997608941            | 
| 500                       | 30.74916015999952      |  0.0055185169985634275           | 
| large                     | ???                    |  26.556534313996963              | 



## Защита от регрессии производительности
Для защиты от потери достигнутого прогресса при дальнейших изменениях программы *о performance-тестах, которые вы написали*

