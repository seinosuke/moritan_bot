# coding: utf-8

module Moritan
  class Function

    include MatrixHelper
    include Matrix
    include Etcetera

    attr_accessor :rep_table, :ssh_config

    def initialize(table, ssh, api_key)
      @rep_table = table
      site_url = "https://sites.google.com/site/moritanbot/home"
      @warning_message = <<-EOS.gsub(/ {6}/,"")
      \nフォーマットが違います
      使い方はこちらを参照してください
      #{site_url}
      EOS
      @random = Random.new(Time.new.to_i)
      @ssh_config={
        username:ssh['username'],
        opt:{
          password:ssh['password'],
          port:22
        }
      }

      # 雑談対話API
      api_url = "https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=#{api_key}"
      @uri = URI.parse(api_url)
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end
end
