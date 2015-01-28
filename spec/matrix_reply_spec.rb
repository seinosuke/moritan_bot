# coding: utf-8

require File.expand_path(Dir.home + '/bot/moritan_bot/spec/spec_helper')

describe 'Moritan::Bot#generate_reply' do

  before do
    @moritanbot = Moritan::Bot.new(debug:true, mention:true)
    @twitter_id = 'rei_debug'
    @reply_id = 334
  end

  subject do
    @moritanbot.generate_reply(contents, @twitter_id, @reply_id)
  end

  describe '行列計算機能' do
    context '階数の場合' do
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
    context '逆行列の場合' do
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
    context '固有値の場合1' do
      let(:contents) do
        <<-EOS
        @#{@moritanbot.name} 固有値
        1, 0, 0
        0, 1, 0
        0, 0, 2
        EOS
      end
      it { is_expected.to eq "1 (重解), 2" }
    end

    # (3重解) がつくか確認
    context '固有値の場合2' do
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
