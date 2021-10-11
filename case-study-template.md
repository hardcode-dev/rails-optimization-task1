# Case-study оптимизации

## Актуальная проблема
В нашем проекте возникла серьёзная проблема.

Необходимо было обработать файл с данными, чуть больше ста мегабайт.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и не было понятно, закончит ли она вообще работу за какое-то разумное время.

Я решил исправить эту проблему, оптимизировав эту программу.

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы я придумал использовать такую метрику - Время работы программы
Но сделать замеры на полных данных невозможно
Поэтому я решил делать замеры на ограниченном датасете
И увеличивать его по мере того как программа будет становится шустрее
решил начать с 10к строк

## Гарантия корректности работы оптимизированной программы
Программа поставлялась с тестом. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.

## Feedback-Loop
Для того, чтобы иметь возможность быстро проверять гипотезы я выстроил эффективный `feedback-loop`, который позволил мне получать обратную связь по эффективности сделанных изменений

Вот как я построил `feedback_loop`:
Я решил положить feedback_loop в папку bin и закоммитить
чтобы в будущем иметь какой-то бойлерплейт код, который можно переиспользовать

Я решил вынести вызовы профилировщиков в методы
также я добавил метод benchmark и asymptotic_analysis в feetback_loop

## Вникаем в детали системы, чтобы найти главные точки роста
Для того, чтобы найти "точки роста" для оптимизации я воспользовался *инструментами, которыми вы воспользовались*

Вот какие проблемы удалось найти и решить

### Сall select method for sessions per each user
- С помощью RubyProf обноружил, что 85% времени тратится на select method
   (все виды отчетов об этом сообщают)
- Stackprof в cli режиме сразу обноружил проблемный код со сложностью O(n^2)
   ```ruby
    users.each do |user|
      # ...
      user_sessions = sessions.select { |session| session['user_id'] == user['id'] }
      # ...
    end
   ```
- Я решил предварительно сгруппировать sessions по user_id
  ```ruby
    user_sessions_groups = sessions.group_by { |session| session['user_id'] }
    users.each do |user|
      # ...
      user_sessions = user_sessions_groups[user['id']]
      # ...
    end
  ```
- метрика уменьшилась с ~4.4s до 0.6s
  асимптотика все еще нелинейная 
- Исправленная проблема перестала быть главной точкой роста

### Use push (<<) instead of [] + []
- С помощью RubyProf обноружил, что 70% времени тратится на each method
  Но когда я грепнулся по each, было не понятно в каком конкретно месте это происходит
  Т.К each очень часто встречается
  Чтобы локализовать проблему решил снова использовать Stackprof в cli режиме
  И обноружил проблемное место
  ```ruby
    file_lines.each do |line|
      yield if block_given?
  
      cols = line.split(',')
      users = users + [parse_user(line)] if cols[0] == 'user'
      sessions = sessions + [parse_session(line)] if cols[0] == 'session'
    end
  ```
  но Stackprof подсветил each как узкое место
  а эти строки судя по отчету почти не занимали время
   ```ruby
        users = users + [parse_user(line)] if cols[0] == 'user'
        sessions = sessions + [parse_session(line)] if cols[0] == 'session'
  ```
  но в это было сложно поверить и я решил их закомментить вместе с остальным кодом
  в результате - код выполнился моментально
  я понял что это и есть главная точка роста и причина квадратичной сложности 
- я переписал проблемный код вот так:
```ruby
    users << parse_user(cols) if cols[0] == 'user'
    sessions << parse_session(cols) if cols[0] == 'session'
```
- Метрика уменьшилась с 3.5s до 0.6s
  Асимптотика стала близкой к линейной
  (Я увеличил тестовый набор в 4 раза т.к мне было тяжело отследить разницу из-за O(n2))
- Проблема перестала быть главной точкой роста

### Repalce custom uniq with built-in uniq
- RubyProf в flat режиме обноружил что 40% времени расходуется на `all?`
- Проблемный код
```ruby
  uniqueBrowsers = []
  sessions.each do |session|
    browser = session['browser']
    uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
  end
  report['uniqueBrowsersCount'] = uniqueBrowsers.count
```
заменил на
```ruby
  report['uniqueBrowsersCount'] = sessions.uniq { |session| session['browser'] }.count
```
- Метрика уменьшилась 2.5s до 1.5s (Тестовый набор был увеличен в 2 раза)
- Проблема перестала быть главной точкой роста

### Replace slow Date.parse with Date.strptime
- С помощью RubyProf в CallStack режиме я обноружил что на этот раз педалит `collect_stats_from_users`
  примерно 60% времени тратится на этот метод.
  Но он вызывается несколько раз в разных местах и поэтому я снова воспользовался Stackprof в cli режиме
  Самым затратным оказался вызов `collect_stats_from_users` с Date.parse
- Я переписал
  ```ruby
    { 'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
  ```
  на
  ```ruby
    { 'dates' => user.sessions.map{ |s| s['date'] }.map { |d| Date.strptime(d, '%Y-%m-%d').iso8601 }.sort.reverse }
  ```
- В результате метрика уменьшилась с 7s до 4s (Тестовый набор был увеличен в 2 раза до 200_000 строк)
- Проблема перестала быть главной точкой роста

### Remove another [] + [] in users_objects
- Прогнав RubyProf в CallStack я увидел что программа тратит по ~40% времени на `each` и `collect_stats_from_users`
- грепнувшись по each я сразу обноружил уже встречавшуюся проблему
    ```ruby
      users.each do |user|
        #...
        users_objects = users_objects + [user_object]
      end
    ```
    тут напрашивается замена each на map
    ```ruby
      users.map do |user|
        #...
        user_object
      end
    ```
- В результате метрика уменшилась с ~6s до ~2.5s (Объем данных не изменился)
  (Я понял что для бенчмарков нужно включать GC, поэтому метрика "просела" по сравнению с предыдущим замером)
  асимптотика почти линейная:
  ```
  1000 -   0.02028300001984462
  2000 -   0.02500199998030439
  4000 -   0.04871100001037121
  8000 -   0.0887090000032913
  16000 -  0.14560099999653175
  32000 -  0.2978640000219457
  64000 -  0.6113849999965169
  128000 - 1.2832579999812879
  256000 - 2.7324589999916498
  512000 - 5.783004999975674
  ```
- Проблема перестала быть главной точкой роста

### `collect_stats_from_users` traverse users several times
- Прогнав RubyProf в CallStack я увидел что программа тратит ~67% времени на `collect_stats_from_users`
  Stackprof в cli режиме показал что на этот раз `collect_stats_from_users` все 7 вызовов тратят примерно похожее время
  Я внимательнее посмотрел на код и увидел - что мы каждый раз пробегаемся по users
  и некоторые блоки `collect_stats_from_users` имееют почти идентичный код
- я решил собрать все вызовы в одном месте и тем самым делать обход users 1 раз
  вот что получилось
  ```ruby
    def collect_stats_from_users(users_objects)
      users_objects.each_with_object({}) do |user, stats|
        user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
        stats[user_key] = {
          # Собираем количество сессий по пользователям
          'sessionsCount' => user.sessions.count,
          # Собираем количество времени по пользователям
          'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.',
          # Выбираем самую длинную сессию пользователя
          'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.',
          # Браузеры пользователя через запятую
          'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', '),
          # Хоть раз использовал IE?
          'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
          # Всегда использовал только Chrome?
          'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
          # Даты сессий через запятую в обратном порядке в формате iso8601
          'dates' => user.sessions.map{ |s| s['date'] }.map { |d| Date.strptime(d, '%Y-%m-%d').iso8601 }.sort.reverse
        }
      end
    end 
  ```
  - метрика уменьшилась с 6s до 4.8s  (тестовый набор увеличен в 2 раза - 400_000 строк)
  
  - Дальше я решил замемоизировать все повторяющиеся части
    Так главной точкой роста по-прежнему остается `collect_stats_from_users`
  ```ruby
    def collect_stats_from_users(users_objects)
     users_objects.each_with_object({}) do |user, stats|
       user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
       session_times = user.sessions.map { |s| s['time'].to_i }
       session_browsers = user.sessions.map { |s| s['browser'].upcase }
       stats[user_key] = {
         # Собираем количество сессий по пользователям
         'sessionsCount' => user.sessions.count,
         # Собираем количество времени по пользователям
         'totalTime' => session_times.sum.to_s + ' min.',
         # Выбираем самую длинную сессию пользователя
         'longestSession' => session_times.max.to_s + ' min.',
         # Браузеры пользователя через запятую
         'browsers' => session_browsers.sort.join(', '),
         # Хоть раз использовал IE?
         'usedIE' => session_browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
         # Всегда использовал только Chrome?
         'alwaysUsedChrome' => session_browsers.all? { |b| b =~ /CHROME/ },
         # Даты сессий через запятую в обратном порядке в формате iso8601
         'dates' => user.sessions.map { |s| Date.strptime(s['date'], '%Y-%m-%d').iso8601 }.sort.reverse
       }
     end
    end
  ```
  выйграл еще 0.5s
  - Самой дорогой точкой остается 
  ```ruby
    'dates' => user.sessions.map { |s| Date.strptime(s['date'], '%Y-%m-%d').iso8601 }.sort.reverse
  ```
  она занимает 24% времени выполнения метода, но очевидного способа ускорить ее пока не вижу
  - поправил еще пару "очевидных" мест вслепую но какого-то ощутимого буста не получил :)
 
## Результаты
В результате проделанной оптимизации наконец удалось обработать файл с данными.
Удалось улучшить метрику системы с ꝏ (система килила процесс) до 45s что достаточно близко к заданному бюджету.

Мне очень понравился StackProf с его cli, с помощью него очень легко искать проблемные места в простых программах

## Защита от регрессии производительности
Для защиты от потери достигнутого прогресса при дальнейших изменениях программы


