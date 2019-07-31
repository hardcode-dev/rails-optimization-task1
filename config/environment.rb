require 'bundler'

Bundler.require(:default)

require 'benchmark'
require 'json'
require 'pry'
require 'date'

$LOAD_PATH << File.expand_path('lib', __dir__)

Dir[Dir.pwd + '/lib/**/*.rb'].each do |file|
  require file
end
