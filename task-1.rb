# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'ruby-progressbar'

FILE_NAME = 'data_large.txt'.freeze

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

def work
  file_lines = File.read(FILE_NAME).split("\n")
  line_count = file_lines.size.to_f
  browsers_map = {}
  report = { totalUsers: 0, uniqueBrowsersCount: 0, totalSessions: 0, allBrowsers: '', usersStats: {} }
  user_key = ''
  progressbar = ProgressBar.create(total: line_count, format: '%a, %J, %E %B')

  file_lines.each do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      user_key = "#{cols[2]}" + ' ' + "#{cols[3]}"
      report[:usersStats][user_key] ||= {}

      report[:totalUsers] += 1
      next
    end

    # Собираем количество сессий по пользователям
    report[:usersStats][user_key][:sessionsCount] ||= 0
    report[:usersStats][user_key][:sessionsCount] += 1 

    # Собираем количество времени по пользователям
    report[:usersStats][user_key][:totalTime] ||= '0 min.'
    total_time = report[:usersStats][user_key][:totalTime]
    report[:usersStats][user_key][:totalTime] = "#{total_time.split(' ').first.to_i + cols[4].to_i} min."

    # Выбираем самую длинную сессию пользователя
    report[:usersStats][user_key][:longestSession] ||= '0 min.'
    longest_session = report[:usersStats][user_key][:longestSession].split(' ').first.to_i
    report[:usersStats][user_key][:longestSession] = "#{[longest_session, cols[4].to_i].max} min."

    # Браузеры пользователя через запятую
    report[:usersStats][user_key][:browsers] ||= ''
    browsers_arr = report[:usersStats][user_key][:browsers].split(', ')
    current_browser = cols[3].upcase
    report[:usersStats][user_key][:browsers] = (browsers_arr << current_browser).sort.join(', ')

    # Хоть раз использовал IE?
    report[:usersStats][user_key][:usedIE] ||= current_browser.start_with?('INTERNET EXPLORER')

    # Всегда использовал только Chrome?
    alwaysUsedChrome = report[:usersStats][user_key][:alwaysUsedChrome]
    report[:usersStats][user_key][:alwaysUsedChrome] = alwaysUsedChrome.nil? ?
    current_browser.start_with?('CHROME') : !!alwaysUsedChrome
    if report[:usersStats][user_key][:alwaysUsedChrome].eql?(true)
      report[:usersStats][user_key][:alwaysUsedChrome] = current_browser.start_with?('CHROME')
    end

    # Даты сессий через запятую в обратном порядке в формате iso8601
    report[:usersStats][user_key][:dates] ||= []
    dates = report[:usersStats][user_key][:dates]
    report[:usersStats][user_key][:dates] = (dates << cols[5]).sort.reverse

    browsers_map[current_browser] ||= 0
    browsers_map[current_browser] += 1

    # Количество всех сессий
    report[:totalSessions] += 1
    progressbar.increment
  end

  # Подсчёт количества уникальных браузеров
  report[:uniqueBrowsersCount] = browsers_map.size

  # Запись уникальных браузеров
  report[:allBrowsers] = browsers_map.keys.sort.join(',')

  File.write('result.json', "#{report.to_json}\n")
end

class TestMe < Minitest::Test
  def setup
    File.write('result.json', '')
    File.write('data.txt',
'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
user,2,Gregory,Santos,86
session,2,0,Chrome 35,6,2018-09-21
session,2,1,Safari 49,85,2017-05-22
session,2,2,Firefox 47,17,2018-02-02
session,2,3,Chrome 20,84,2016-11-25
')
  end

  def test_result
    work
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end
