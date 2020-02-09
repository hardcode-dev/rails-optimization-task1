require 'oj'
require 'date'

def parse_user_and_session(user_data)

  browsers, times, dates = user_data[1..-1].map do |session|
    browser, time, date = *session.split(',')[2..5]
    [browser.upcase, time.to_i, date]
  end.transpose

  [
      [ # собранныя статистика по пользователю
          user_data[0].split(',')[1..2].join(' '),
          {
              'sessionsCount' =>user_data.size - 1,
              'totalTime' => "#{times.sum} min.",
              'longestSession' => "#{times.max} min.",
              'browsers' => browsers.sort.join(', '),
              'usedIE' => browsers.any?{ |b| b.start_with?('INTERNET EXPLORER') },
              'alwaysUsedChrome' => browsers.all?{ |b| b.start_with?('CHROME') },
              'dates' => dates.sort.reverse
          }
      ],
      browsers, #массив браузеров пользователя
  ]
end

def work(source_data_file = 'data.txt', disable_gc = false)
  GC.disable if disable_gc

  grouped_user_data = File.read(source_data_file).split("\nuser,").map{ |ss| ss.split("\nsession,") }

  grouped_user_data[0][0]['user,'] = '' # Перед первым пользователем нет символа новой строки,

  parsed_user_data = grouped_user_data.map{ |user_data| parse_user_and_session(user_data ) }

  # Отчёт в json
  #   - Сколько всего юзеров +
  #   - Сколько всего уникальных браузеров +
  #   - Сколько всего сессий +
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
  #
  #   - По каждому пользователю
  #     - сколько всего сессий +
  #     - сколько всего времени +
  #     - самая длинная сессия +
  #     - браузеры через запятую +
  #     - Хоть раз использовал IE? +
  #     - Всегда использовал только Хром? +
  #     - даты сессий в порядке убывания через запятую +

  report = {}

  report['totalUsers'] = parsed_user_data.size

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = parsed_user_data.flat_map { |user_data| user_data[1] }.uniq

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = parsed_user_data.sum{ |user_data| user_data[0][1]['sessionsCount'] }

  report['allBrowsers'] = uniqueBrowsers.sort.join(',')

  # Статистика по пользователям

  report['usersStats'] = parsed_user_data.map(&:first).to_h

  File.write('result.json', Oj.dump(report)+"\n")
end































