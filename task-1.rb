require_relative 'report'

report = Report.new(ARGV[0] || 'data.txt').to_json
File.write('result.json', "#{report.to_json}\n")
