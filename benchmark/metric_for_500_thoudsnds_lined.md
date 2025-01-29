## Case 3
### Метрика на 500 тысячах строк
* Finish in 12.99

### Бюджет на метрику
~6 секунды на обработку data_500_thousands_lines.txt

### Пишу спеку (для фиксации текущей метрики)
`rspec spec/work_performance_spec.rb:25`

### Применил профилировщик stackprof speedscope
6.84 секунд Array#each

`user_object = User.new(attributes: attributes, sessions: user_sessions)`

`users_objects = users_objects + [user_object]`

**Решение:**

Убираю лишнее присваивание, добавляю в существующий массив(users_object) данные

**Результат после оптимизационных действий**
Метрика снизилась c 12.99 секунд до 6.9 секунд (~ в 2 раза)

### Обновил спеку
`rspec spec/work_performance_spec.rb:19`

----

### Новая итерация (бюджет тот же ~6 секунды)
5.18 секунд Array#each
```
sessions.each do |session|
browser = session['browser']
uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
end
```

**Решение**
Использую Set для выбора уникальных браузеров

**Результат после оптимизационных действий**
Метрика снизилась c 6.9 до 4.92 (~ в 1.4 раза)

### Обновил спеку
`rspec spec/work_performance_spec.rb:19`
