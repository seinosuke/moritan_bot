#!/usr/bin/env ruby
# coding: utf-8

$:.unshift File.join(Dir.home, '/bot/moritan_bot/lib/')
require 'moritan'

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
    end
  end

  every(1.hour, 'tweet', :at => $times)
end
