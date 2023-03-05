# Case-study оптимизации

## Первоночальная регрессия
with GC
- 10000 lines: Finished in 1.305206s, 0.7662 runs/s
- 20000 lines: Finished in 5.388734s, 0.1856 runs/s
- 40000 lines: Finished in 34.189398s, 0.0292 runs/s.

without GC
- 10000 lines: Finished in 1.644167s, 0.6082 runs/s
- 20000 lines: Finished in 9.194758s, 0.1088 runs/s
- 40000 lines: Finished in 85.458254s, 0.0117 runs/s

Зависимость N^2+

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы использовать время выполнение программы

## Feedback-Loop
`feedback_loop`: 
- Запустить профайлеры(ruby-prof(Flat,Graph,CallStack,CallTree),stackprof(CLI,speedscope.app), rbspy)
- Найти проблеммный метод
- Отрефакторить
- Прогнать тесты
- Закомитить


### 1.Array#select
- flat: в users.each: user_sessions = sessions.select { |session| session['user_id'] == user['id'] }
- Перед users.each сделать sessions.group_by{ |s| s['user_id'] }
- Время для 20к линий сократилось в ~2.5 9.16->2.09
- Исправленная проблема перестала быть главной точкой роста

### 2.Array#+
- speed_score: в file_lines.each: users + [parse_user(line)] и др.
- Заменил с users + [parse_user(line)] и и на users << parse_user(line)
- Время для 40к линий сократилось в ~8 8.50 ->0.98
- Исправленная проблема перестала быть главной точкой роста

### 3.Array#all?
- graph: в uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
- Заменил на report['uniqueBrowsersCount'] = sessions.map{|s| s['browser']}.uniq.count
- Время для 200к линий сократилось в ~2.5 14 ->6
- Исправленная проблема перестала быть главной точкой роста

### 4.collect_stats_from_users и Date.parse
- speedscore: 
- Убрал лишние map, Избавился от Date.parse так как лишний(скорее всего)
- Время для 500к линий сократилось в ~2 8->4
- Исправленная проблема перестала быть главной точкой роста

### 4.String#split
- speedscore:
- Убрал лишний вызов split
- Время для 1500к линий сократилось на ~15% 11.3->9.7
- Исправленная проблема осталось быть главной точкой роста

### 5. map, лишний проход по пользователям
- speedscore:
- В set_stats_from_user убраны несколько лишних мапов, и сам вызов происходит не на групп, а на каждого пользователя при первом проходе
- Время для data_large 22 сек(с выключенным GC)
- Точками роста остались split, и map, sort, any в set_stats_from_user

## Результаты
- В результате проделанной оптимизации удалось обработать данный файл менее чем за 30 секунд.
- По большей части использовал профайлер speedscore, так как в нем есть одновременно есть несколько форматов отображения(Time Order, Left Heavy и Sandwich).
- Не удалось довести асимптотику до линейной.


## Защита от регрессии производительности
- Написаны тесты на порог скорости и ips(task-1_spec.rb)
- Написан тест на линейную асимптотику, который не проходит.

