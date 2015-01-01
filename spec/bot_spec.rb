# coding: utf-8

$:.unshift File.join(Dir.home, '/bot/moritan_bot/lib/')
require 'moritan'

describe Moritan::Bot do

  #
  # Twitter::REST::Client.new を
  # モック(ここでは@twitter_client_mock)にしている
  # @moritanbot(→self)がself.clientされたときモックを返す
  # 例えば#postの場合、中で self.client.update("foo") しているので
  # モックは updateメソッドを呼び出せるようにする必要がある
  #
  before do
    @moritanbot = Moritan::Bot.new(debug:true, mention:true)
    @twitter_client_mock = double('Twitter client')
    allow(@moritanbot).to receive(:client).and_return(@twitter_client_mock)
  end

  #
  # 投稿に関するテスト
  #
  describe '#post' do
    context '正常に投稿できた場合' do
      it do
        allow(@twitter_client_mock).to receive(:update)
        printf "    投稿内容： "
        expect{ @moritanbot.post("foo") }.not_to raise_error
      end
    end

    context '投稿時にエラーが発生した場合' do
      it 'もう一度postを試みる' do
        allow(@twitter_client_mock).to receive(:update).and_raise(Twitter::Error)
        expect(@moritanbot).to receive(:post)
        @moritanbot.post("foo")
      end
    end

    context '140文字以上の投稿を要求された場合' do
      it 'chain_postが呼ばれる' do
        allow(@twitter_client_mock).to receive(:update)
        expect(@moritanbot).to receive(:chain_post)
        @moritanbot.post('foo'*100)
      end
    end
  end # #post

  #
  # お気に入り登録に関するテスト
  #
  describe '#fav' do
    context '正常にお気に入り登録できた場合' do
      it do
        allow(@twitter_client_mock).to receive(:favorite)
        expect{ @moritanbot.fav(334) }.not_to raise_error
      end
    end

    context 'お気に入り登録時にエラーが発生した場合' do
      it do
        allow(@twitter_client_mock).to receive(:favorite).and_raise(Twitter::Error)
        expect( @moritanbot.fav(334) ).to be_nil
      end
    end
  end # #fav
end
