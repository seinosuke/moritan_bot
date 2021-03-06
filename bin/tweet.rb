#!/usr/bin/env ruby
# coding: utf-8

require File.expand_path(Dir.home + '/bot/moritan_bot/lib/moritan')

debug = false
OptionParser.new do |opt|
  opt.on('-d', '--debug','Switch to debug mode'){|v| debug = v}
  opt.parse!(ARGV)
end

puts "debug mode" if debug
$moritanbot = Moritan::Bot.new(debug:debug)
$times = ['00:00','04:00','08:00','10:00','12:00','14:00','16:00','20:00']

module Clockwork
  handler do |job|
    case job
    when 'tweet'
      text = $moritanbot.config['ReplayTable']['terms'].sample
      $moritanbot.post(text)
    when 'page'
      puts `ruby #{Moritan::BASE_DIR}bin/scrape.rb`
    when 'backup'
      puts `ruby #{Moritan::BASE_DIR}control/export.rb`
    end
  end

  every(1.hour, 'tweet', :at => $times)
  every(1.day, 'page', :at => '15:00')
  every(1.day, 'backup', :at => '05:00')
end
