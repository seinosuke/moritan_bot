# coding: utf-8

module Moritan
  class Function

    include Moritan::Matrix
    include Moritan::Etcetera

    attr_accessor :rep_table

    def initialize(rep_table, config)
      @rep_table = rep_table
      @config = config
      @error_message = @config['error_message']
      @random = Random.new(Time.new.to_i)

      # 雑談対話API
      api_url = "https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=#{@config['api_key']}"
      @uri = URI.parse(api_url)
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end


    # メンションじゃない投稿のキーワードを判断し返しを選ぶ
    def get_response_text(contents = "")
      case contents
      when @rep_table['self'][0]
        if contents.match(@function.rep_table['call'][0])
          @rep_table['call'][1].sample
        end
      else nil
      end
    end

    # メンションに含まれるキーワードを判断し機能を呼び出す
    def get_function_text(contents = "", twitter_id = "")
      case contents
      when /^(階数)/   then get_rank_str(contents)
      when /^(逆行列)/ then get_invmat_str(contents)
      when /^(行列式)/ then get_det_str(contents)
      when /^(2|3|4|２|３|４)乗$/ then get_power_str(contents)
      when /^(固有値)/ then get_eigen_str(contents)

      when /(計算機室|機室|きしつ)/ then get_ping_result
      when /(単位|たんい)/ then get_gacha_result(contents, twitter_id)
      when /(成績|GPA)/ then get_record_str(twitter_id)
      when /(図書館|としょかん)/ then get_opening_hours

      else # どのキーワードにも当てはまらなかったら
        get_reply_text(contents, twitter_id)
      end
    end
  end
end
