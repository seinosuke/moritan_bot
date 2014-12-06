# coding: utf-8

module Moritan
  module Etcetera

    def mark(contents)
      if contents =~ /の単位/
        subject = contents.split(/の単位/)[0]
        if subject.size > 11 || subject.empty?
          subject = "線形代数"
        end
      end
      subject ||= "線形代数"
      rarity = @random.rand(100)
      grade = case rarity
        when 0..4   then "A+"
        when 5..10  then "A"
        when 11..29 then "B"
        when 30..69 then "C"
        when 70..99 then "D"
        end

      text = "あなたの#{subject}の単位は#{grade}です"
      text += " 来年もがんばってください" if grade == "D"
      return text
    end

    # どのキーワードにも当てはまらなかったら
    def converse(contents)
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

      text ||= talk(contents)
      text ||= @rep_table['terms'].sample
      return text
    end

    module_function

    def talk(contents)
      uri = URI.parse("https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=#{@api_key}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      body = Hash['utt' => contents]
      request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' =>'application/json'})
      request.body = body.to_json
      response = http.start do |h|
        resp = h.request(request)
        JSON.parse(resp.body)
      end
      return response['utt']
    rescue JSON::ParserError
      return
    end
  end
end
