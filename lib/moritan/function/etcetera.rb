# coding: utf-8

module Moritan
  module Etcetera

    # 単位ガチャ
    def get_gacha_result(contents, twitter_id)
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
        Moritan::User.create_user(twitter_id)
      end
      user = Moritan::DataBase.new(twitter_id)
      gpa = user.get_gpa(grade)
      text =  "あなたの#{subject}の単位は#{grade[1]}です"
      text += " 来年もがんばってください" if grade[1] == "D"
      text += " [GPA: %.2f]".% gpa.round(2)
      return text
    end

    # 現在のGPA等を返す
    def get_record_text(twitter_id)
      unless Moritan::DataBase.exist?(twitter_id:twitter_id)
        Moritan::User.create_user(twitter_id)
      end
      user = Moritan::DataBase.new(twitter_id)
      members_num = Moritan::DataBase.last_id
      text = <<-EOS.gsub(/^ +/, "").%(user.credit.gpa.round(2))
      \n合計履修単位数 #{user.credit.total}単位
      GPAランキング #{members_num}人中#{user.rank}位
      [GPA: %.2f]
      EOS
      return text
    end

    # 図書館の開館時間を返す
    def get_opening_hours
      url = "http://www.tulips.tsukuba.ac.jp/lib/"
      doc = Nokogiri::HTML(open(url)) rescue return
      opening_hours = doc.xpath("//span[@class='opening-hours']").text
        if opening_hours == "休館"
          return "本日中央図書館は休館です"
        else
          return "本日の中央図書館開館時間は#{opening_hours}です"
        end
    end

    # どのキーワードにも当てはまらなかったら
    def get_response_text(contents, twitter_id)
      text = nil
      catch(:exit) do
        if contents.match(@rep_table['self'][0])
          text = @rep_table['self'][1].sample
          throw :exit
        end

        @rep_table['mention'].each do |row|
          if row[0].any? {|keyword| contents.index(keyword) }
            text = row[1].sample
            throw :exit
          end
        end
      end

      text ||= request_response(contents, twitter_id)
      text ||= @rep_table['terms'].sample
      return text
    end

    module_function

    # 雑談対話
    def request_response(contents, twitter_id)
      # ユーザーが登録されていなかったら新しく作る
      unless Moritan::DataBase.exist?(twitter_id:twitter_id)
        Moritan::User.create_user(twitter_id)
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
