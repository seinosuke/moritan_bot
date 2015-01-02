# coding: utf-8

require File.expand_path(Dir.home + '/bot/moritan_bot/spec/spec_helper')

describe 'Moritan::Bot#generate_reply' do

  before do
    @user1 = create(:user)
    @user2 = create(:user)
    pp @user1
    pp @user1.credit
    pp @user2
    pp @user2.credit
  end

  it { expect(true).to be_truthy }
end
