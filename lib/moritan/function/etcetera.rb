# coding: utf-8

module Moritan
  module Etcetera

    # 単位ガチャ
    def mark(contents, twitter_id)
      if contents =~ /の単位/
        subject = contents.split(/の単位/)[0]
        if subject.size > 20 || subject.empty?
          subject = "線形代数"
        end
      end
      subject ||= "線形代数"
      rarity = @random.rand(100)
      grade = case rarity
        when 0..4   then ["aa", "A+"]
        when 5..10  then ["a",  "A" ]
        when 11..29 then ["b",  "B" ]
        when 30..69 then ["c",  "C" ]
        when 70..99 then ["d",  "D" ]
        end

      # ユーザーが登録されていなかったら新しく作る
      unless Moritan::DataBase.exist?(twitter_id:twitter_id)
        Moritan::User.entry(twitter_id)
      end
      user = Moritan::DataBase.new(twitter_id)
      gpa = user.get_gpa(grade)
      text =  "あなたの#{subject}の単位は#{grade[1]}です"
      text += " 来年もがんばってください" if grade[1] == "D"
      text += " [GPA: %.2f]".% gpa.round(2)
      return text
    end

    # 現在のGPA等を返す
    def record(twitter_id)
      unless Moritan::DataBase.exist?(twitter_id:twitter_id)
        Moritan::User.entry(twitter_id)
      end
      user = Moritan::DataBase.new(twitter_id)
      members_num = Moritan::DataBase.last_id
      text = "\nこれまでの履修単位数は#{user.credit.total}" +
             "\nGPAは%.2fです".%(user.credit.gpa.round(2)) +
             "\n[GPAランキング #{members_num}人中#{user.rank}位]"
      return text
    end

    # どのキーワードにも当てはまらなかったら
    def converse(contents, twitter_id)
      text = nil
      catch(:exit) do
        if contents.match(@rep_table['self'][0])
          text = @rep_table['self'][1].sample
          throw :exit
        end

        @rep_table['comprehensible'].each do |row|
          if row[0].any? {|keyword| contents.index(keyword) }
            text = row[1].sample
            throw :exit
          end
        end
      end

      text ||= get_response(contents, twitter_id)
      text ||= @rep_table['terms'].sample
      return text
    end

    module_function

    # 雑談対話
    def get_response(contents, twitter_id)
      # ユーザーが登録されていなかったら新しく作る
      unless Moritan::DataBase.exist?(twitter_id:twitter_id)
        Moritan::User.entry(twitter_id)
      end
      user = Moritan::DataBase.new(twitter_id)

      if user.last_date == Time.now.strftime("%Y%m%d")
        context = user.context
      end
      context ||= ""
      body = {'utt' => contents, 'context' => context}
      request = Net::HTTP::Post.new(@uri.request_uri, {'Content-Type' =>'application/json'})
      request.body = body.to_json
      response = nil
      @http.start do |h|
        resp = h.request(request)
        response = JSON.parse(resp.body)
      end
      user.context = response['context']
      return response['utt']
    rescue JSON::ParserError, SocketError
      user.context = ""
      return
    end
  end
end
