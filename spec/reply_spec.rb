# coding: utf-8

$:.unshift File.join(Dir.home, '/bot/moritan_bot/lib/')
require 'moritan'

describe Moritan::Bot do

  before do
    @moritanbot = Moritan::Bot.new(debug:true, mention:true)
    @twitter_id = 'rei_debug'
    @reply_id = 334
  end

  context '行列計算(階数の例)' do
    it do
      contents = <<-EOS.gsub(/ {4}/,"")
      @#{@moritanbot.name} 階数
      1, 0
      0, 1
      EOS
      rep_text = @moritanbot.generate_reply(contents, @twitter_id, @reply_id)
      expect(rep_text).to eq "2"
    end
  end
end
