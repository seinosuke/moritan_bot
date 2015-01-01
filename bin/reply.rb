#!/usr/bin/env ruby
# coding: utf-8

$:.unshift File.join(Dir.home, '/bot/moritan_bot/lib/')
require 'moritan'

debug = false
OptionParser.new do |opt|
  opt.on('-d', '--debug','Switch to debug mode'){|v| debug = v}
  opt.parse!(ARGV)
end

moritanbot = Moritan::Bot.new(debug:debug, mention:true)

puts "debug mode" if debug
puts "ready!"

begin
  moritanbot.timeline.userstream do |status|

    twitter_id = status.user.screen_name
    contents   = status.text
    status_id  = status.id
    reply_id   = status.in_reply_to_status_id

    not_RT     = status.retweeted_status.nil?
    isMention  = status.user_mentions.any? { |user| user.screen_name == moritanbot.name }
    isReply    = contents.match(/^@\w*/)

    # リツイート以外を取得
    if not_RT
      # リプライでない通常の投稿であれば
      unless isReply
        res_text = moritanbot.generate_response(contents, status_id, moritanbot)
        if res_text
          moritanbot.post(res_text, twitter_id:twitter_id, status_id:status_id)
        end
      end

      # 自分へのリプであれば
      if isMention
        rep_text = moritanbot.generate_reply(contents, twitter_id, reply_id)
        if rep_text
          moritanbot.post(rep_text, twitter_id:twitter_id, status_id:status_id)
        end
      end
    end

    sleep 2
  end

rescue Interrupt
  exit 1
rescue
  error_logs("reply")
  sleep 30
  retry
end
