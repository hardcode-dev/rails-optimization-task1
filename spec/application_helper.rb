require 'spec_helper'

ENV['RACK_ENV'] ||= 'test'

require_relative '../config/environment'

Dir[ApplicationLoader.root.concat('/spec/support/**/*.rb')].sort.each { |f| require f }
