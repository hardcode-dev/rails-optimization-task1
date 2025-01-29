### Case 4

### Метрика на 3_250_940 строк
Finish in 35.71

### Бюджет
оптимизировать не менее 30 секунд на обработку data_large.txt

### Пишу спеку (для фиксации текущей метрики)
`rspec spec/work_performance_spec.rb:31`

### Применил профилировщик stackprof speedscope
collect_stats_from_users
(self: 9.7%, 3.41 sec / total: 41%, 14.56 )

Чуть редактирую следующих код

`report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))`

на

`report['usersStats'][user_key].merge!(block.call(user))` - без создания нового хеша, модификация имеющегося

-- Всё что ниже без дополнительного массива, модифицируем в один заход.

`user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.'`

на

`user.sessions.map {|s| s['time']}.sum(&:to_i).to_s + ' min'`

--

`user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.' }`

на

`user.sessions.map {|s| s['time'].to_i}.max.to_s + ' min.'`

--

`user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ')`

на

`user.sessions.map { |s| s['browser'].upcase }.sort.join(', ')`

--

`user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ }`

на

`user.sessions.any? { |s| s['browser'].upcase =~ /INTERNET EXPLORER/ }`

--

`user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ }`

на

`user.sessions.all? { |s| s['browser'].upcase =~ /CHROME/ }`

--

`user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 }`

на

`user.sessions.map { |s| s['date'] }.sort.reverse` -- можно не вызывать Date.parse(это была следующая точка роста по отчету)

**Результат после оптимизационных действий**

Не сильный прирост, но в бюджет уложился Finish in 24.53 (~ в 1.4 раза)

### Обновил тест на производительность
`rspec spec/work_performance_spec.rb:31`

