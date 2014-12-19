# coding: utf-8

ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  "database" => Moritan::DB_FILE
)

module Moritan
  class User < ActiveRecord::Base

    validates :twitter_id, :presence => true, :uniqueness => true
    I18n.enforce_available_locales = false
    has_one :credit, :dependent => :destroy

    class << self

      # 新規登録
      def entry(twitter_id="")
        user = self.new do |u|
          u.twitter_id = twitter_id
          u.context = ""
          u.last_date = Time.now
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
      def clear(id:nil)
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
      def show_contents(id:nil)
        if id
          user = self.find(id)
          puts "id         #{user.id}"
          puts "twitter_id #{user.twitter_id}"
          puts "context    #{user.context}"
          puts "last_date  #{user.last_date}"
        else
          self.all.each do |u|
            puts "id         #{u.id}"
            puts "twitter_id #{u.twitter_id}"
            puts "context    #{u.context}"
            puts "last_date  #{u.last_date}"
          end
        end
      rescue
        error_logs("show_contents", $!, $@)
      end
    end
  end
end
