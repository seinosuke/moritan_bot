# coding: utf-8

ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  "database" => "../lib/moritan/database/moritan_bot.db"
)

module Moritan
  class User < ActiveRecord::Base

    validates :twitter_id, :presence => true, :uniqueness => true
    I18n.enforce_available_locales = false
    has_one :credit, :dependent => :destroy

    # 新規登録
    def User::entry(twitter_id="")
      user = self.new do |u|
        u.twitter_id = twitter_id
      end
      user.save

      # first_or_createをしなくてよくなる
      credit = Moritan::Credit.new do |c|
        c.user_id = user.id
        c.aa_times = 0
        c.a_times  = 0
        c.b_times  = 0
        c.c_times  = 0
        c.d_times  = 0
        c.gpa      = 0.00
        c.total    = 0
      end
      credit.save
    end

    # 情報の削除（id指定無しで全員）
    def User::clear(id:nil)
      if id
        user = self.find(id)
        user.destroy
        user.save
      else
        self.destroy_all
      end
    rescue
      error_logs("clear", $!, $@)
    end

    # userの情報を表示（id指定無しで全員表示）
    def User::show_contents(id:nil)
      if id
        user = self.find(id)
        puts "id         #{user.id}"
        puts "twitter_id #{user.twitter_id}"
      else
        self.all.each do |u|
          puts "id         #{u.id}"
          puts "twitter_id #{u.twitter_id}"
        end
      end
    rescue
      error_logs("show_contents", $!, $@)
    end
  end
end
