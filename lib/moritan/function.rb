# coding: utf-8

module Moritan
  class Function

    include Matrix
    include Etcetera

    attr_accessor :rep_table, :ssh_config

    def initialize(table, ssh)
      @rep_table = table
      site_url = "https://sites.google.com/site/moritanbot/home"
      @warning_message = "\nフォーマットが違います\n" +
                         "使い方はこちらを参照してください\n#{site_url}"
      @random = Random.new(Time.new.to_i)
      @ssh_config={
        username:ssh['username'],
        opt:{
          password:ssh['password'],
          port:22
        }
      }
    end
  end
end
