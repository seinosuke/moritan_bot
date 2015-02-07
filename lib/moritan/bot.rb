# coding: utf-8

module Moritan
  class Bot

    attr_reader \
      :config,
      :function, :name,
      :client, :timeline

    def initialize(debug:false, mention:false)
      load_config(debug)

      @client = Twitter::REST::Client.new do |c|
        c.consumer_key        = @CONSUMER_KEY
        c.consumer_secret     = @CONSUMER_SECRET
        c.access_token        = @OAUTH_TOEKN
        c.access_token_secret = @OAUTH_TOEKN_SECRET
      end

      if mention then
        TweetStream.configure do |c|
          c.consumer_key       = @CONSUMER_KEY
          c.consumer_secret    = @CONSUMER_SECRET
          c.oauth_token        = @OAUTH_TOEKN
          c.oauth_token_secret = @OAUTH_TOEKN_SECRET
          c.auth_method = :oauth
        end
        @timeline = TweetStream::Client.new
      end
    end

    def load_config(debug = true)
      @config = YAML.load_file(Moritan::CONF_FILE)

      @function = Moritan::Function.new(@config['ReplayTable'], @config['Function'])
      @name = debug ? @config['name_debug'] : @config['name']

      oauth = debug ? 'oauth_debug' : 'oauth'
      @CONSUMER_KEY       = @config[oauth]['consumer_key']
      @CONSUMER_SECRET    = @config[oauth]['consumer_secret']
      @OAUTH_TOEKN        = @config[oauth]['oauth_token']
      @OAUTH_TOEKN_SECRET = @config[oauth]['oauth_token_secret']
    end

    # 通常の投稿
    def post(text = "", twitter_id:nil, status_id:nil)
      text = twitter_id ? "@#{twitter_id} #{text}" : text

      if text.size > 140
        over_text = text
        twitter_id_size = twitter_id ? ("@#{twitter_id}".size + 1) : 0
        # ↓”＠〜”と”（続く）”4文字を除いた最終的にpostに返せる最大文字数で分割
        post_size = 140 - (twitter_id_size + 4)
        post_text, *over_text = text.reverse.scan(/.{1,#{post_size}}/m)
        post("#{over_text.join.reverse}(続く)", twitter_id:twitter_id, status_id:status_id)
      end

      post_text = post_text ? post_text.reverse : text
      self.client.update(post_text, in_reply_to_status_id: status_id)
      puts post_text

    # Twitter::Error::RequestTimeout: exection expired
    rescue Twitter::Error
      try ||= 0
      try += 1
      error_logs("#{try}回目のpost")
      sleep 1
      retry if try < 3
    end

    # ふぁぼる
    def fav(status_id = nil)
      if status_id
        self.client.favorite(status_id)
      end
    rescue
      error_logs("fav")
    end

    # メンションじゃない投稿に対する返しを生成
    def generate_response(contents, status_id, moritanbot)
      contents = contents_filter(contents)
      moritanbot.fav(status_id)
      res_text = @function.get_response_text(contents)
      res_text
    rescue
      error_logs("generate_response")
    end

    # メンションに対する返しを生成
    def generate_reply(contents, twitter_id, reply_id)
      contents = contents_filter(contents)
      rep_text = @function.get_reply_text(contents, twitter_id)
      rep_text ||= @function.get_reply_str(contents, twitter_id)
      rep_text
    rescue
      error_logs("generate_reply")
    end

    private

    def contents_filter(contents = "")
      contents = contents.gsub(/@\w*/, "")
      contents = contents.gsub(/ |\p{blank}|\t/, "")
      contents
    end
  end
end
