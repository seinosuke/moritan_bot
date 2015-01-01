# coding: utf-8

module Moritan
  class Credit < ActiveRecord::Base

    belongs_to :user

    class << self

      # 状態の削除（id指定無しで全員）
      def clear(id:nil)
        if id
          credit = self.find_by_user_id(id)
          credit.delete
          credit.save
        else
          self.delete_all
        end
      rescue
        error_logs("clear")
      end

      # userの状態一覧を表示（id指定無しで全員表示）
      def show_contents(id:nil)
        if id
          credit = self.find_by_user_id(id)
          user = Moritan::User.find(credit.user_id)
          puts "user_id #{credit.user_id}"
          puts "GPA     #{credit.gpa}"
          puts "total   #{credit.total}"
        else
          self.all.each do |c|
            user = Moritan::User.find(c.user_id)
            puts "user_id #{c.user_id}"
            puts "GPA     #{c.gpa}"
            puts "total   #{c.total}"
          end
        end
      rescue
        error_logs("show_contents")
      end
    end
  end
end