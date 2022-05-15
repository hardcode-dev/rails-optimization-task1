### Сравнительный анализ методов парсинга CSV
При использовании класса CSV для парсинга данных отчет `ruby-prof` показал, что главная точка роста стала находиться в модуле парсинга CSV. Попробовав несколько разных методов парсинга, в том числе с подключением гемов, я не добился желаемых результатов и решил более подробно изучить этот вопрос с использованием `benchmark`. Изучая результаты измерений, я обратил внимание на то, что некоторые варианты работают быстрее с небольшими объемами данных, но резко начинают терять производительность при увеличении обрабатываемых объемов. Поэтому я решил сделать замеры на исходном файле `data_large.txt`. Также стало очевидно, что группировка импортированных данных роняет производительность примерно на 20%, вследствие чего я отказался от ее использования:
```ruby
# 22.742783   0.439124  23.181907 ( 23.213566)
x.report do
  File.open(ENV['DATA_FILE'] || filename, 'r') do |file|
    csv = CSV.new(file, headers: false).group_by { |k| k[0] }
    csv['user'].each { |u| users << parse_user(u) }
    csv['session'].each { |s| sessions << parse_session(s) }
  end
end

# 15.877077   0.342687  16.219764 ( 16.234937)
x.report do
  File.open(ENV['DATA_FILE'] || filename, 'r') do |file|
    csv = CSV.new(file, headers: false)
    csv.each do |line|
      case line[0]
      when 'user' then users << parse_user(line)
      when 'session' then sessions << parse_session(line)
      end
    end
  end
end
```
Результаты измерений времени работы разных методов чтения и парсинга CSV:
```ruby
# 19.620499   0.506042  20.126541 ( 20.152766)
x.report do
  csv = CSV.read(ENV['DATA_FILE'] || filename, headers: false)
  csv.each do |line|
    case line[0]
    when 'user' then users << parse_user(line)
    when 'session' then sessions << parse_session(line)
    end
  end
end

# 19.735521   0.416036  20.151557 ( 20.169527)
x.report do
  csv = CSV.parse(File.read(ENV['DATA_FILE'] || filename), headers: false)
  csv.each do |line|
    case line[0]
    when 'user' then users << parse_user(line)
    when 'session' then sessions << parse_session(line)
    end
  end
end

# 14.799502   0.346270  15.145772 ( 15.158798)
x.report do
  csv = CSV.new(File.read(ENV['DATA_FILE'] || filename), headers: false)
  csv.each do |line|
    case line[0]
    when 'user' then users << parse_user(line)
    when 'session' then sessions << parse_session(line)
    end
  end
end

# 16.443834   0.273161  16.716995 ( 16.732366)
x.report do
  File.open(ENV['DATA_FILE'] || filename, 'r') do |file|
    csv = CSV.new(file, headers: false)
    csv.each do |line|
      case line[0]
      when 'user' then users << parse_user(line)
      when 'session' then sessions << parse_session(line)
      end
    end
  end
end

# 15.938136   0.352901  16.291037 ( 16.304995)
x.report do
  CSV.foreach(ENV['DATA_FILE'] || filename, headers: false) do |line|
    case line[0]
    when 'user' then users << parse_user(line)
    when 'session' then sessions << parse_session(line)
    end
  end
end
```
