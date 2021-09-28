# Case-study оптимизации

## Актуальная проблема
В нашем проекте возникла серьёзная проблема.

Необходимо было обработать файл с данными, чуть больше ста мегабайт.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и не было понятно, закончит ли она вообще работу за какое-то разумное время.

Я решил исправить эту проблему, оптимизировав эту программу.

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы я придумал использовать такую метрику: время выполнения скрипта

## Гарантия корректности работы оптимизированной программы
Программа поставлялась с тестом. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.

## Feedback-Loop
Для того, чтобы иметь возможность быстро проверять гипотезы я выстроил эффективный `feedback-loop`, который позволил мне получать обратную связь по эффективности сделанных изменений за 24 секунды.

Вот как я построил `feedback_loop`: запускал выполнение скрипта с каждым из профайлеров, находил точки роста, которые можно улучшить, вносил позитивные изменения в код для оптимизации узкого места.

## Вникаем в детали системы, чтобы найти главные точки роста
Для того, чтобы найти "точки роста" для оптимизации я воспользовался stackprof, rubyprof, rbspy

Вот какие проблемы удалось найти и решить

### 1. `RubyProf::FlatPrinter` показал, что самое многочисленное - это `select` по массиву.
При старте скрипта с 10_000 записей файле получается вот такой результат:
`select` каждый раз пробегается по огромному массиву из сессий, когда их выбирает для конкретного пользователя.
Т.е. это значит, что сколько пользователей, столько раз он и пробежится по массиву.
```
Total: 5.016776
Sort by: self_time

 %self      total      self      wait     child     calls  name                           location
 87.11      4.370     4.370     0.000     0.000     1536   Array#select
  7.63      4.982     0.383     0.000     4.600    10010  *Array#each
  1.00      0.122     0.050     0.000     0.072    16898   Array#map
  0.92      0.046     0.046     0.000     0.000    20001   String#split
```
Вынесу сохранение сессий в блок с парсингом файла. туда же, куда сохраняю студентов.
Стало:
```
Total: 0.616663
Sort by: self_time

 %self      total      self      wait     child     calls  name                           location
 60.43      0.583     0.373     0.000     0.211    10010  *Array#each
  8.40      0.052     0.052     0.000     0.000    20001   String#split
  7.39      0.123     0.046     0.000     0.077    16898   Array#map
  5.90      0.066     0.036     0.000     0.030     8464   <Class::Date>#parse
```

### 2. `Enumerable#all?`
При просмотре результата выполнения скрипта в `RubyProf::CallStackPrinter` среди всех значений выделяется `Enumerable#all?`.
![image](https://user-images.githubusercontent.com/8101357/135119479-c187600d-f1bb-468e-b28c-ecf4b2470543.png)
Число прохода по браузерам `uniqueBrowsers.all? { |b| b != browser }` не совсем необходимо, т.к. то, что делает эта конструкция, можно забросить в конструкцию `Set` на этапе парсинга.
```
Total: 0.632211
Sort by: self_time

 %self      total      self      wait     child     calls  name                           location
 59.48      0.596     0.376     0.000     0.220    10010  *Array#each
  7.73      0.049     0.049     0.000     0.000    20001   String#split
  7.58      0.133     0.048     0.000     0.085    16898   Array#map
  6.54      0.073     0.041     0.000     0.032     8464   <Class::Date>#parse
  2.41      0.015     0.015     0.000     0.000    16928   Regexp#match
  2.14      0.034     0.014     0.000     0.020     8464   Object#parse_session           task-1.rb:29
```
Стало:
![image](https://user-images.githubusercontent.com/8101357/135120094-5328206f-9b4a-46d8-baf6-12668d0f7823.png)

```
Total: 0.471532
Sort by: self_time

 %self      total      self      wait     child     calls  name                           location
 52.02      0.449     0.245     0.000     0.203     1545  *Array#each
 10.83      0.051     0.051     0.000     0.000    20001   String#split
  8.10      0.108     0.038     0.000     0.069    16896   Array#map
  6.06      0.059     0.029     0.000     0.030     8464   <Class::Date>#parse
  3.03      0.014     0.014     0.000     0.000    16928   Regexp#match
  2.70      0.030     0.013     0.000     0.018     8464   Object#parse_session           task-1.rb:29
```

### 3. подсчёт числа браузеров на этапе парсинга
Т.к. полный массив сессий (который собирается sessions = sessions + [parse_session(line)]) теперь нигде не используется, то можно упростить счётчик общего количества сессий, и вынести его на этап парсинга файла.
Стало:
```
Total: 0.279961
Sort by: self_time

 %self      total      self      wait     child     calls  name                           location
 24.64      0.252     0.069     0.000     0.183     1545  *Array#each
 12.91      0.112     0.036     0.000     0.075    16896   Array#map
 12.84      0.066     0.036     0.000     0.030     8464   <Class::Date>#parse
 11.04      0.031     0.031     0.000     0.000    20001   String#split
  5.05      0.014     0.014     0.000     0.000    16928   Regexp#match
  3.62      0.020     0.010     0.000     0.009     8464   Object#parse_session           task-1.rb:29
```

### 4. замена <Class::Date>#parse на более лёгкий.
![image](https://user-images.githubusercontent.com/8101357/135120648-6035a7b0-03f1-481f-9889-0b5ecb32cccf.png)
т.е. `Date#parse` выполняется долго. заменяю на `Date#strptime`
```
Total: 0.226314
Sort by: self_time

 %self      total      self      wait     child     calls  name                           location
 29.68      0.204     0.067     0.000     0.136     1545  *Array#each
 15.45      0.062     0.035     0.000     0.027    15360   Array#map
 14.17      0.032     0.032     0.000     0.000    20001   String#split
  6.51      0.016     0.015     0.000     0.001     8464   <Class::Date>#strptime
  4.22      0.022     0.010     0.000     0.012     8464   Object#parse_session           task-1.rb:29
```

### 5. лишний `String#split`
![image](https://user-images.githubusercontent.com/8101357/135121528-b2bd3c3c-6d1b-4b85-ae25-391d8af3ed58.png)
т.е. указывает на лишний `parse`, который, в целом, можно измбежать, передавая уже спарсенную строку в методы `parse_session` и `parse_user`
```
Total: 0.211810
Sort by: self_time

 %self      total      self      wait     child     calls  name                           location
 31.94      0.186     0.068     0.000     0.119     1545  *Array#each
 15.41      0.061     0.033     0.000     0.028    15360   Array#map
  9.39      0.020     0.020     0.000     0.000    10001   String#split
  7.90      0.018     0.017     0.000     0.001     8464   <Class::Date>#strptime
  4.50      0.010     0.010     0.000     0.000    10752   Hash#merge
  4.30      0.022     0.009     0.000     0.013        1   JSON::Ext::Generator::GeneratorMethods::Hash#to_json
  3.89      0.008     0.008     0.000     0.000    25366   String#encode
  3.31      0.007     0.007     0.000     0.000     8464   Object#parse_session           task-1.rb:29
```

### 6. уменьшаем время работы GC
Увиличив до 100000 строк в файле, выполнилось ±5 сек.
Пробую запустить на 1000000 строк. ожадаю ±50 сек, но получилось дольше.

```
Total: 189.428301
Sort by: self_time

 %self      total      self      wait     child     calls  name                           location
 79.55    186.937   150.697     0.000    36.240   153779  *Array#each
 11.72     22.199    22.199     0.000     0.000  1000001   String#split
  1.89      3.575     3.575     0.000     0.000   846230   Object#parse_session           task-1.rb:30
  1.84      5.945     3.489     0.000     2.457  1537700   Array#map
  0.76      1.569     1.446     0.000     0.123   846230   <Class::Date>#strptime
  0.69      1.312     1.312     0.000     0.000  1076390   Hash#merge
  0.55      2.046     1.049     0.000     0.997        1   JSON::Ext::Generator::GeneratorMethods::Hash#to_json
  0.36      0.687     0.687     0.000     0.000  2525385   String#encode
  0.32      0.607     0.607     0.000     0.000   846230   Set#add                        /Users/liveafun/.rvm/rubies/
```
![image](https://user-images.githubusercontent.com/8101357/135122431-a62e3c0b-cc0c-4330-ba4b-23ff878bf875.png)

В `StackProf` обнаружилось, что крайне много от всего выполнения скрипта рабоает ГЦ.
Есть подозрение, что много памяти потребляется при добавлении элементов в массив.
Т.е. конструкции:
`users = users + [parse_user(cols)]`
`users_objects = users_objects + [user_object]`
заменю на
`users << parse_user(cols)`
`users_objects << user_object`
и скрипт будет выполняться быстрее.
В результате время выполнения скрипта стало лучше:
```
Total: 26.999868
Sort by: self_time

 %self      total      self      wait     child     calls  name                           location
 26.44     24.363     7.138     0.000    17.225   153779  *Array#each
 14.56      7.586     3.932     0.000     3.655  1537700   Array#map
  9.08      2.451     2.451     0.000     0.000  1000001   String#split
  8.75      2.480     2.363     0.000     0.117   846230   <Class::Date>#strptime
  6.94      1.873     1.873     0.000     0.000  1076390   Hash#merge
  6.18      1.917     1.670     0.000     0.247   307541   Array#sort
  3.86      1.043     1.043     0.000     0.000   846230   Object#parse_session           task-1.rb:30
```
![image](https://user-images.githubusercontent.com/8101357/135122927-1fedebde-0e95-47aa-a693-e2a49bef4e52.png)

### 7. часто вызывается `Object#collect_stats_from_users` и долго работает.
Суммарно, чень долго отрабатывает метод Object#collect_stats_from_users (принимает блок, при обработке данных пользователя):
```
==================================
  Mode: wall(1000)
  Samples: 21827 (0.95% miss rate)
  GC: 11518 (52.77%)
==================================
     TOTAL    (pct)     SAMPLES    (pct)     FRAME
     10309  (47.2%)        7063  (32.4%)     Object#work
      6811  (31.2%)        6811  (31.2%)     (marking)
      4707  (21.6%)        4707  (21.6%)     (sweeping)
      7174  (32.9%)        2039   (9.3%)     Object#collect_stats_from_users
       577   (2.6%)         577   (2.6%)     Object#parse_session
       279   (1.3%)         279   (1.3%)     User#initialize
       207   (0.9%)         207   (0.9%)     Object#parse_user
       143   (0.7%)         143   (0.7%)     Set#add
```
Внутри него действия происходят однотипные - собираются хеши по уже имеющимся данным, просто вызывается часто и результат различается всего лишь наименованием ключей. Самое оптимальное, это свести все его вызовы в одну конструкцию.
Итог:
`RubyProf`:
```
Total: 18.504831
Sort by: self_time

 %self      total      self      wait     child     calls  name                           location
 23.27     15.129     4.306     0.000    10.822   153773  *Array#each
 12.19      2.255     2.255     0.000     0.000  1000001   String#split
 10.47      2.055     1.937     0.000     0.118   846230   <Class::Date>#strptime
  8.69      4.580     1.609     0.000     2.971   615080   Array#map
  6.27      1.160     1.160     0.000     0.000   846230   Object#parse_session           task-1.rb:29
```
`StackProf`:
```
==================================
  Mode: wall(1000)
  Samples: 14983 (1.71% miss rate)
  GC: 8547 (57.04%)
==================================
     TOTAL    (pct)     SAMPLES    (pct)     FRAME
      5272  (35.2%)        5272  (35.2%)     (marking)
      6436  (43.0%)        4807  (32.1%)     Object#work
      3275  (21.9%)        3275  (21.9%)     (sweeping)
       570   (3.8%)         570   (3.8%)     Object#parse_session
      3294  (22.0%)         394   (2.6%)     Object#collect_stats_from_users
       250   (1.7%)         250   (1.7%)     User#initialize
       245   (1.6%)         245   (1.6%)     Object#parse_user
       169   (1.1%)         169   (1.1%)     Set#add
         1   (0.0%)           1   (0.0%)     Set#initialize
      8547  (57.0%)           0   (0.0%)     (garbage collection)
      6436  (43.0%)           0   (0.0%)     <main>
      6436  (43.0%)           0   (0.0%)     block in <main>
      6436  (43.0%)           0   (0.0%)     <main>
```
### 8. Hash#merge
Пробую на полных данных - там ±3млн записей.
Ожидаю, что выполнится за 60 сек. Получилось: 71.444675.
`StackProf` показал точку роста в методе `collect_stats_from_users`.
`stackprof stackprof_reports/stackprof.dump --method 'Object#collect_stats_from_users'`
Выхлоп:
```
Object#collect_stats_from_users (/Users/liveafun/Documents/GitHub/thnk/rails-optimization-task1/task-1.rb:38)
  samples:  1359 self (2.3%)  /   11273 total (18.8%)
  callers:
    11273  (  100.0%)  Object#collect_stats_from_users
    11273  (  100.0%)  Object#work
  callees (9914 total):
    11273  (  113.7%)  Object#collect_stats_from_users
    9914  (  100.0%)  Object#work
  code:
                                  |    38  | 
 11273   (18.8%)                  |    39  | def collect_stats_from_users(report, users_objects, &block)
  280    (0.5%) /   280   (0.5%)  |    40  |   users_objects.each do |user|
  327    (0.5%) /   327   (0.5%)  |    41  |     user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
 9914   (16.5%)                   |    42  |     report['usersStats'][user_key] ||= {}
  752    (1.3%) /   752   (1.3%)  |    43  |     report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
                                  |    44  |   end
```
В связи с тем, что инфа по пользователю была вынесена в один блок, то конструкцию:
```
report['usersStats'][user_key] ||= {}
report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
```
можно оптимизировать ещё:
```
report['usersStats'][user_key] = block.call(user)
```
т.е. `merge` не нужен.
Получилось: 54.618795.

### 9. Снова GC
![image](https://user-images.githubusercontent.com/8101357/135124574-a74553fa-8f28-4c3c-a3eb-1075e2feecdc.png)
```
==================================
  Mode: wall(1000)
  Samples: 57298 (1.52% miss rate)
  GC: 37229 (64.97%)
==================================
     TOTAL    (pct)     SAMPLES    (pct)     FRAME
     26251  (45.8%)       26251  (45.8%)     (marking)
     20069  (35.0%)       15928  (27.8%)     Object#work
     10978  (19.2%)       10978  (19.2%)     (sweeping)
      1626   (2.8%)        1626   (2.8%)     Object#parse_session
       858   (1.5%)         858   (1.5%)     User#initialize
       694   (1.2%)         694   (1.2%)     Object#parse_user
       499   (0.9%)         499   (0.9%)     Set#add
      9989  (17.4%)         463   (0.8%)     Object#collect_stats_from_users
         1   (0.0%)           1   (0.0%)     Set#initialize
```
Явно, имеются проблемы с ГЦ - более 40% работы приходится на него.
В общем, много памяти используется.
- Стоит попробовать избавиться от аггрегации массива `users`, и дальнейшей итерации по нему. Это можно сделать, т.к. мы уже формируем хеш с сессиями, в котором все эти же пользователи и содержатся. поэтому и значит, что для избавления от лишнего использования памяти стоит итерироваться по нему.
- В добавок, сократить потребление памяти и уменьшить работу ГЦ, если избавимся от использования класса `User`.
- Так же, если избавиться от методов `parse_user` и `parse_session`, то можно сократить лишние преобразования спарсенных с помощью `split(',')` строк из файла, которые преобразуются в хеш. Конечно, обращение к элементам массива менее наглядно, чем к значениям хеша по его ключу, но, зато, это быстрее.
- Cтоит заметить, что даты в файле сохранены в формате `'%Y-%m-%d'`. Это значит, что можно убрать лишнее конвертирование в дату, и произвестит сортировку именно уже имеющихся строк.
В результате: 24.770388

## Результаты
В результате проделанной оптимизации наконец удалось обработать файл с данными.
Удалось улучшить метрику системы с ∞ до 24 сек и уложиться в заданный бюджет.

## Защита от регрессии производительности
Для защиты от потери достигнутого прогресса при дальнейших изменениях программы *о performance-тестах, которые вы написали*
