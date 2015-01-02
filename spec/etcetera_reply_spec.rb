# coding: utf-8

require File.expand_path(Dir.home + '/bot/moritan_bot/spec/spec_helper')

describe 'Moritan::Bot#generate_reply' do

  before do
    @moritanbot = Moritan::Bot.new(debug:true, mention:true)
    @twitter_id = twitter_id
    @reply_id = 334
  end

  # データベースに保存される
  let(:registered_user) { create(:user) }

  subject do
    @moritanbot.generate_reply(contents, @twitter_id, @reply_id)
  end

  describe '単位ガチャ' do
    let(:contents) { '単位' }

    context '既にデータベースに登録されているユーザの場合' do
      let(:twitter_id) { registered_user.twitter_id }
      it { expect { is_expected }.to change{ Moritan::User.last.id }.by(0) }
    end

    #
    # 未登録ユーザが初めてガチャをする場合
    # 同時に新規登録もされるのでユーザ数が増える
    #
    context 'まだデータベースに登録されていないユーザの場合' do
      let(:twitter_id) { 'rei_debug_1' }
      it { expect { is_expected }.to change{ Moritan::User.last.id }.by(1) }
    end
  end

  describe '成績開示要求' do
    let(:contents) { '成績' }

    context '既にデータベースに登録されているユーザの場合' do
      let(:twitter_id) { registered_user.twitter_id }
      it { expect { is_expected }.to change{ Moritan::User.last.id }.by(0) }
    end

    #
    # 単位ガチャと同様の説明
    #
    context 'まだデータベースに登録されていないユーザの場合' do
      let(:twitter_id) { 'rei_debug_2' }
      it { expect { is_expected }.to change{ Moritan::User.last.id }.by(1) }
    end
  end
end
