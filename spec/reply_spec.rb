# coding: utf-8

$:.unshift File.join(Dir.home, '/bot/moritan_bot/lib/')
require 'moritan'

describe Moritan::Bot do

  before do
    @moritanbot = Moritan::Bot.new(debug:true, mention:true)
    @twitter_id = 'rei_debug'
    @reply_id = 334
  end

  subject do
    @moritanbot.generate_reply(contents, @twitter_id, @reply_id)
  end

  describe '#generate_reply' do
    context '行列計算(階数の例)' do
      let(:contents) do
        <<-EOS
        @#{@moritanbot.name} 階数
        1, 0
        0, 1
        EOS
      end
      it { is_expected.to eq "2" }
    end

    # 行列の形になって返ってきているか確認
    context '行列計算(逆行列の例)' do
      let(:contents) do
        <<-EOS
        @#{@moritanbot.name} 逆行列
        1, 0
        0, 1
        EOS
      end
      it { is_expected.to eq "\n1, 0\n0, 1" }
    end

    # (重解) がつくか確認
    context '行列計算(固有値の例1)' do
      let(:contents) do
        <<-EOS
        @#{@moritanbot.name} 固有値
        1, 0, 0
        0, 1, 0
        0, 0, 2
        EOS
      end
      it { is_expected.to eq "1 (重解)、 2" }
    end

    # (3重解) がつくか確認
    context '行列計算(固有値の例2)' do
      let(:contents) do
        <<-EOS
        @#{@moritanbot.name} 固有値
        1, 0, 0
        0, 1, 0
        0, 0, 1
        EOS
      end
      it { is_expected.to eq "1 (3重解)" }
    end
  end
end
