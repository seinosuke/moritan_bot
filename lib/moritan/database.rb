# coding: utf-8

module Moritan
  class DataBase

    attr_accessor \
      :id, :twitter_id, :last_date,
      :credit

    class << self
      def last_id
        return Moritan::User.last.id
      end

      # 存在するか
      def exist?(id:nil, twitter_id:nil)
        if id
          Moritan::User.find(id)
          return true
        elsif twitter_id
          return Moritan::User.find_by_twitter_id(twitter_id) ? true : false
        end
      rescue ActiveRecord::RecordNotFound
        return false
      end
    end

    def initialize(twitter_id="")
      @user = Moritan::User.find_by_twitter_id(twitter_id)
      @id = @user.id
      @last_date = @user.last_date.strftime("%Y%m%d")
      @twitter_id = twitter_id
      @credit = Moritan::Credit.find_by_user_id(@id)
    rescue
      error_logs("database initialize")
      return nil
    end

    def context
      @user.context
    end

    def context= (value)
      @user.context = value
      @user.save
    end

    # 現在までのGPAを計算して返す
    def get_gpa(grade)
      eval("@user.credit.#{grade[0]}_times += 1")
      @user.credit.total += 1
      gpa = (@user.credit.aa_times*4 + @user.credit.a_times*3  +
             @user.credit.b_times*2  + @user.credit.c_times*1) /
             @user.credit.total.to_f
      @user.credit.gpa = gpa
      @user.credit.save
      return gpa
    rescue
      error_logs("entrance")
      return 0.0
    end

    # GPAランキング
    def rank
      my_rank = Moritan::User.last.id
      Moritan::User.all.each do |u|
        next if @id == u.id
        my_rank -= 1 if u.credit.gpa <= @user.credit.gpa
      end
      return my_rank
    end
  end
end
