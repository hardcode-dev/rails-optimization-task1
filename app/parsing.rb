class Parsing
  attr_reader :file_name, :disable_bar

  def initialize(file_name, disable_bar)
    @file_name = file_name
    @disable_bar = disable_bar
  end

  def call
    file_lines = File.read(file_name).split("\n")
    bar = Bar.new(file_lines.count).progress unless disable_bar

    result = {}

    file_lines.each do |line|
      bar.increment unless disable_bar

      fields = line.split(',')

      if fields[0] == 'user'
        id = fields[1]

        result[id] = {
          first_name: fields[2],
          last_name: fields[3],
          age: fields[4],
          sessions: {}
        }

        next
      end

      user_id = fields[1]
      browser = fields[3].upcase
      time = fields[4].to_i
      date = fields[5]
      sessions = result[user_id][:sessions]
      sessions[:items] ||= {}

      sessions[:total_time] ||= 0
      sessions[:total_time] += time

      sessions[:long_session] ||= 0
      sessions[:long_session] = time if time > sessions[:long_session]

      sessions[:browsers] ||= []
      sessions[:browsers].push(browser)

      sessions[:dates] ||= []
      sessions[:dates].push(date)

      sessions[:items][fields[2]] = {
        browser: browser,
        time: time,
        date: date
      }
    end

    result
  end
end
