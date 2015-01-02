# coding: utf-8

FactoryGirl.define do
  factory :user ,class: Moritan::User do
    context ""
    last_date Time.now
    sequence(:twitter_id) {|i| "foo#{i}" }
    credit { create(:credit) }
  end
end
