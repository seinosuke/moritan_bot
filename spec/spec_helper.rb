# coding: utf-8

require File.expand_path(Dir.home + '/bot/moritan_bot/lib/moritan')
require 'factory_girl'

ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  "database" => Moritan::TEST_DB_FILE
)
Moritan::Credit.clear
Moritan::User.clear

require File.expand_path(Dir.home + '/bot/moritan_bot/spec/factories/users')
require File.expand_path(Dir.home + '/bot/moritan_bot/spec/factories/credits')

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
