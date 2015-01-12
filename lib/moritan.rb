# coding: utf-8
$:.unshift File.dirname(__FILE__)

require 'twitter'
require 'tweetstream'
require 'yaml'
require 'pp'
require 'active_record'
require 'open3'
require 'uri'
require 'net/http'
require 'net/ping'
require 'net/ssh'
require 'matrix'
require 'complex'
require 'prime'
require 'nkf'
require 'open-uri'
require 'nokogiri'
require 'clockwork'
require 'json'
require 'openssl'

require_relative "moritan/extensions"

def error_logs(text = "")
  puts Time.now
  puts "#{text} error! #{$!.class}: #{$!}\n#{$@[0]}"
end

module Moritan

  class ExceptionForMatrix::ErrNotHermitian < StandardError; end

  BASE_DIR     = File.join(Dir.home, '/bot/moritan_bot/')
  CONF_FILE    = File.join(Moritan::BASE_DIR, 'bin/config.yml')
  DB_FILE      = File.join(Moritan::BASE_DIR, 'bin/moritan_bot.db')
  TEST_DB_FILE = File.join(Moritan::BASE_DIR, 'bin/test.db')

  require_relative "moritan/user"
  require_relative "moritan/credit"
  require_relative "moritan/database"

  require_relative "moritan/matrix_helper"
  require_relative "moritan/matrix"
  require_relative "moritan/pcnode"
  require_relative "moritan/pcroom"
  require_relative "moritan/etcetera"
  require_relative "moritan/function"

  require_relative "moritan/bot"
end
