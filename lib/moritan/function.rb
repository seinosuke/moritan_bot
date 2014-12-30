# coding: utf-8

module Moritan
  class Function

    include Moritan::Matrix
    include Moritan::Etcetera

    attr_accessor :rep_table

    NOT_HERMITIAN_ERRMSG = 
      "成分に虚数を含む行列の固有値計算はエルミート行列のみ対応しています"

    INVALID_FORMAT_ERRMSG = <<-EOS.gsub(/ {6}/,"")
      \nフォーマットが違います
      使い方はこちらを参照してください
      https://sites.google.com/site/moritanbot/home
      EOS

    def initialize(table, api_key)
      @rep_table = table
      @random = Random.new(Time.new.to_i)

      # 雑談対話API
      api_url = "https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=#{api_key}"
      @uri = URI.parse(api_url)
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def get_ping_result(ssh_config)
      room = Moritan::PCroom.new(2..91, timeout:3, ssh:ssh_config)
      "\n現在90台中#{room.count(:on)}台稼働中"
    end
  end
end
