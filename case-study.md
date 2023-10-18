Прогнал программу на разных по размеру файлах, время работы увеличивалось в 5 раз при удвоении объема данных

Использовал rbspy, результат
```
% self  % total  name
97.49    99.91  block in work - task-1.rb:56
1.92     1.92  split [c function] - (unknown)
0.36     1.37  parse_session - task-1.rb:36
0.14     0.23  parse_user - task-1.rb:25
```
Построил отчет ruby-prof
```
%self      total      self      wait     child     calls
name
 69.33     33.080    24.360     0.000     8.720     3811   Array#select
 25.45      8.942     8.942     0.000     0.000 82918202   String#==
  1.37      1.124     0.482     0.000     0.642    25000   Array#all?
  1.21      0.639     0.424     0.000     0.215  2116921   BasicObject#!=
```
Больше всего времени уходит на Array#select

Выделил выборку сессий в переменную grouped_user_sessions, которая считается сразу по всем юзерам

На объеме 20к строк время работы сократилось с 5 секунд до 0.3 секунды, большой файл все еще обрабатывается долго

Прогнал еще раз ruby-prof
```
 %self      total      self      wait     child     calls  name
 24.82      1.106     0.477     0.000     0.629    25000   Array#all?
 21.50      0.627     0.413     0.000     0.214  2116921   BasicObject#!=
 11.50      0.221     0.221     0.000     0.000  2166923   String#==
  9.74      1.892     0.187     0.000     1.705       11   Array#each
  8.53      0.164     0.164     0.000     0.000    29011   Array#+
```
Больше всего времени уходит на Array#all?

Для выяснения какой именно Array#all? занимает много времени вынес проверку на использование Chrome в отдельный метод #always_used_chrome?
```
%self      total      self      wait     child     calls  name
0.15      0.015     0.003     0.000     0.012     3811   Object#always_used_chrome?
```
Явно не то, значит нужно оптимизировать
```
uniqueBrowsers.all? { |b| b != browser }
```

Переписал на
```
sessions.uniq { |session| session['browser'] }.count
```

На объеме 50к строк время работы сократилось с 2.6 секунд до 2.3 секунды, большой файл все еще обрабатывается долго

Прогнал еще раз ruby-prof
```
%self      total      self      wait     child     calls  name
 19.96      0.160     0.160     0.000     0.000    28811   Array#+
 17.81      0.764     0.142     0.000     0.621       10   Array#each
 13.87      0.111     0.111     0.000     0.000    50001   String#split
  9.59      0.198     0.077     0.000     0.122    41923   Array#map
```
Больше всего времени уходит на Array#+

В коде много мест с использованием этого метода, вынес получение users и sessions в метод fetch_users_and_sessions(filename)
```
%self      total      self      wait     child     calls  name
 19.51      0.751     0.153     0.000     0.598       10   Array#each
 18.56      0.146     0.146     0.000     0.000    28811   Array#+
 14.47      0.114     0.114     0.000     0.000    50001   String#split
  8.94      0.186     0.070     0.000     0.116    41923   Array#map
  0.00      0.381     0.000     0.000     0.381        1   Object#fetch_users_and_sessions /home/peplum/dev/rails-optimization-task1/task-1.rb:50
```
Попробую профилировщик graph
![Alt text](<images/Screenshot from 2023-10-15 17-26-05.png>)

Теперь видно, что почти все время занимают два метода: `Object#fetch_users_and_sessions` и `Object#collect_stats_from_users`
Начнем оптимизацию с `Object#fetch_users_and_sessions`
Вот и проблемный `Array#+`
```
users += [parse_user(line)] if cols[0] == 'user'
sessions += [parse_session(line)] if cols[0] == 'session'
```
лучше заменить на `Array#<<`
```
first_column = line.split(',').first
users << parse_user(line) if first_column == 'user'
sessions << Zparse_session(line) if first_column == 'session'
```
На объеме 50к строк время работы сократилось с 2.3 секунд до 1.3 секунды, большой файл все еще обрабатывается долго

Оптимизируем `Object#collect_stats_from_users`

Метод по коду вызывается 7 раз, кажется, можно переписать на однократное использование
```
collect_stats_from_users(report, users_objects) do |user|
  { 'sessionsCount' => user.sessions.count }
end
collect_stats_from_users(report, users_objects) do |user|
  { 'totalTime' => user.sessions.map { |s| s['time'] }.map { |t| t.to_i }.sum.to_s + ' min.' }
end
collect_stats_from_users(report, users_objects) do |user|
  { 'longestSession' => user.sessions.map { |s| s['time'] }.map { |t| t.to_i }.max.to_s + ' min.' }
end
collect_stats_from_users(report, users_objects) do |user|
  { 'browsers' => user.sessions.map { |s| s['browser'] }.map { |b| b.upcase }.sort.join(', ') }
end
collect_stats_from_users(report, users_objects) do |user|
  { 'usedIE' => user.sessions.map { |s| s['browser'] }.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
end
collect_stats_from_users(report, users_objects) do |user|
  always_used_chrome?(user)
end
collect_stats_from_users(report, users_objects) do |user|
  { 'dates' => user.sessions.map { |s| s['date'] }.map { |d| Date.parse(d) }.sort.reverse.map { |d| d.iso8601 } }
end
```
Стало
```
collect_stats_from_users(report, users_objects) do |user|
  {
    'sessionsCount' => user.sessions.count,
    'totalTime' => user.sessions.map { |s| s['time'] }.map { |t| t.to_i }.sum.to_s + ' min.',
    'longestSession' => user.sessions.map { |s| s['time'] }.map { |t| t.to_i }.max.to_s + ' min.',
    'browsers' => user.sessions.map { |s| s['browser'] }.map { |b| b.upcase }.sort.join(', '),
    'usedIE' => user.sessions.map { |s| s['browser'] }.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome' => user.sessions.map { |s| s['browser'] }.all? { |b| b.upcase =~ /CHROME/ },
    'dates' => user.sessions.map { |s| s['date'] }.map { |d| Date.parse(d) }.sort.reverse.map { |d| d.iso8601 }
  }
end
```
На объеме 100к строк время работы сократилось с 3.6 секунд до 3.1 секунды, большой файл все еще обрабатывается долго

![Alt text](<images/Screenshot from 2023-10-15 18-11-23.png>)

`Object#collect_stats_from_users` все еще самый затратный

![Alt text](<images/Screenshot from 2023-10-15 21-31-53.png>)

`Array#map` занимает большую часть выполнения `Object#collect_stats_from_users`

Избавился от лишних `Array#map`
```
collect_stats_from_users(report, users_objects) do |user|
  user_sessions = user.sessions
  session_browsers = []
  session_times = []
  user_sessions.each do |session|
    session_browsers << session['browser'].upcase
    session_times << session['time'].to_i
  end

  {
    'sessionsCount' => user_sessions.count,
    'totalTime' => "#{session_times.sum} min.",
    'longestSession' => "#{session_times.max} min.",
    'browsers' => session_browsers.sort.join(', '),
    'usedIE' => session_browsers.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome' => session_browsers.all? { |b| b.upcase =~ /CHROME/ },
    'dates' => user_sessions.map { |s| Date.parse(s['date']).iso8601 }.sort.reverse
  }
end
```
На объеме 100к строк время работы сократилось с 3.1 секунд до 2.5 секунды, большой файл все еще обрабатывается долго

Прогоняю kcachegrind
![Alt text](<images/Screenshot from 2023-10-16 00-55-51.png>)

Провалившись в `Array#map` вижу, что `Date.parse` занимает очень большое время, перепроверил во что парсится - результат тот же, что и инпут, можно избавиться

На объеме 300к строк время работы сократилось с 8.7 секунд до 8.15 секунды, большой файл все еще обрабатывается долго

Вижу, что `String#split` занимает много времени, заменяю
```
file_lines.each do |line|
  first_column = line.split(',').first
  users << parse_user(line) if first_column == 'user'
  sessions << parse_session(line) if first_column == 'session'
end
```
на
```
file_lines.each do |line|
  columns = line.split(',')
  users << parse_user(columns) if columns[0] == 'user'
  sessions << parse_session(columns) if columns[0] == 'session'
end
```
На результат времени работы почти не повлияло или вообще не повлияло, смотрел на разных выборках от 10к до 300к строк

![Alt text](<images/Screenshot from 2023-10-17 00-11-44.png>)
Смотрю другие части кода, которые еще не проверял, попробую просмотреть где еще можно оптимизировать `Array#map`
```
report['allBrowsers'] =
    sessions
    .map { |s| s['browser'] }
    .map { |b| b.upcase }
    .sort
    .uniq
    .join(',')
```
Заменяю на
```
report['allBrowsers'] = sessions.map { |s| s['browser'].upcase }.sort.uniq.join(',')
```
На объеме 300к строк время работы сократилось с 8.15 секунд до 7.76 секунды, большой файл все еще обрабатывается долго

Дальше отчет в kcachegrind перестал быть показательным, попробовал отчет stackprof
![Alt text](<images/Screenshot from 2023-10-18 00-11-29.png>)
Видно, что слишком много времени уходит на
```
users_objects += [user_object]
```
оптимизируем
```
users.each do |user|
  attributes = user

  users_objects << User.new(attributes: attributes, sessions: grouped_user_sessions[user['id']])
end
```
На объеме 300к строк время работы сократилось с 7.76 секунд до 6.34 секунды, большой файл обработался за 75 секунд

![Alt text](<images/Screenshot from 2023-10-18 00-36-57.png>)
Прогнал stackprof, попробую оптимизировать места с `String#split`

Заменил
```
file_lines = File.read(ENV['DATA_FILE'] || filename || 'data300000.txt').split("\n")
users = []
sessions = []

file_lines.each do |line|
  columns = line.split(',')
  users << parse_user(columns) if columns[0] == 'user'
  sessions << parse_session(columns) if columns[0] == 'session'
end
```
на
```
File.foreach(ENV['DATA_FILE'] || filename || 'data300000.txt') do |line|
  columns = line.split(',')
  users << parse_user(columns) if columns[0] == 'user'
  sessions << parse_session(columns) if columns[0] == 'session'
end
```
Время обработки большого файла снизилось с 45 секунд до 35, оптимизация еще важная тем, что файл не будет съедать всю память, и, что еще важнее, вызовы GC будут реже

Далее я пробегался по файлу в поисках очевидных оптимизаций. Находки:
1. Решил глянуть файл с данными, оказалось, что юзеры и сессии появляются лишь раз, т.е. можно избавиться от группировки сессиий по юзерам, делать это сразу при чтении файла. Оставлю это на потом, нужно будет много правок, лучше пока поискать оптимизации попроще
2. Заменил все #count на #size
3. Заменил #merge на #merge!

Время обработки большого файла снизилось с 35 секунд до 30, уже успех, но я потратил еще немного времени и выполнил пункт 1

Теперь метод Object#fetch_users_and_sessions собирает только массив users
```
if columns[0] == 'user'
  users << parse_user(columns)
else
  users.last[:sessions] << parse_session(columns)
end
```
в Object#parse_user добавил ключ :sessions, в методе `Object#work` массив sessions теперь формируется так:
```
sessions = users.flat_map { |user| user[:sessions] }
```
Таким образом, можно полностью избавиться от следующего кода
```
users_objects = []
grouped_user_sessions = sessions.group_by { |session| session[:user_id] }
users.each do |user|
  attributes = user

  users_objects << User.new(attributes: attributes, sessions: grouped_user_sessions[user[:id]])
end
```
Время обработки большого файла снизилось с 30 секунд до 24, на этом думаю можно остановиться
