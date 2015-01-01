# coding: utf-8

module Moritan
  class Bot

    attr_accessor \
      :config,
      :function, :name,
      :client, :timeline

    def initialize(debug:false, mention:false)
      @config = YAML.load_file(Moritan::CONF_FILE)

      @ssh_config = @config['ssh']
      @function = Moritan::Function.new(@config['ReplayTable'], @config['api_key'])
      @name = debug ? @config['name_debug'] : @config['name']

      oauth = debug ? 'oauth_debug' : 'oauth'
      @CONSUMER_KEY       = @config[oauth]['consumer_key']
      @CONSUMER_SECRET    = @config[oauth]['consumer_secret']
      @OAUTH_TOEKN        = @config[oauth]['oauth_token']
      @OAUTH_TOEKN_SECRET = @config[oauth]['oauth_token_secret']

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


    # 通常の投稿
    def post(text = "", twitter_id:nil, status_id:nil, try:0)
      # 会話の返事
      if status_id
        rep_text = "@#{twitter_id} #{text}"
        if rep_text.size > 140
          rep_text = self.chain_post(text,twitter_id:twitter_id,status_id:status_id)
        end
        @client.update(rep_text,{:in_reply_to_status_id => status_id})
        puts "#{rep_text}\n\n"

      # ただの投稿(twitter_id:nil)か会話の始まり
      else
        post_text = twitter_id ? "@#{twitter_id} #{text}" : text
        if post_text.size > 140
          post_text = self.chain_post(text,twitter_id:twitter_id,status_id:status_id)
        end
        @client.update(post_text)
        puts "#{post_text}\n\n"
      end

    # Twitter::Error::RequestTimeout: exection expired
    rescue Twitter::Error
      try += 1
      error_logs("#{try}回目のpost")
      sleep 1
      retry if try < 3
    end


    # 140文字を超える投稿(分割投稿後140文字以下の最後の投稿を返す)
    def chain_post(text = "", twitter_id:nil, status_id:nil, try:0)
      over_text = text
      twitter_id_size = twitter_id ? ("@#{twitter_id}".size + 1) : 0

      # ↓”＠〜”と”（続く）”4文字を除いた最終的にpostに返せる最大文字数で分割
      post_size = 140 - (twitter_id_size + 4)
      texts = over_text.scan(/.{1,#{post_size}}/m)

      begin
        0.upto(texts.size - 2) do |i|
          texts[i] = twitter_id ? "@#{twitter_id} #{texts[i]}(続く)" : "#{texts[i]}(続く)"
          @client.update(texts[i],{:in_reply_to_status_id => status_id})
          puts "#{texts[i]}\n\n"
        end
      rescue Twitter::Error
        try += 1
        error_logs("#{try}回目のchain_post")
        sleep 1
        retry if try < 3
      end

      return "@#{twitter_id} #{texts[texts.size - 1]}"
    end

    # ふぁぼる
    def fav(status_id)
      if status_id
        @client.favorite(status_id)
      end
    rescue
      error_logs("fav")
    end

    # メンションじゃない投稿に反応
    def generate_response(contents, status_id, moritanbot)
      res_text = nil
      contents = contents.gsub(/@\w*/,"")
      contents = contents.gsub(/(\s|\p{blank})/,"")
      case contents
      when @function.rep_table['self'][0]
        moritanbot.fav(status_id)
        if contents.match(@function.rep_table['call'][0])
          res_text = @function.rep_table['call'][1].sample
        end
      end
      return res_text

    rescue
      error_logs("generate_response")
    end

    # メンションに反応
    def generate_reply(contents, twitter_id, reply_id)
      contents = contents.gsub(/@\w*/,"")
      contents = contents.gsub(/ |\p{blank}|\t/,"")
      rep_text = case contents
        when /^(階数)/   then @function.get_rank_str(contents)
        when /^(逆行列)/ then @function.get_invmat_str(contents)
        when /^(行列式)/ then @function.get_det_str(contents)
        when /^(固有値)/ then @function.get_eigen_str(contents)

        when /(計算機室|機室|きしつ)/ then @function.get_ping_result(@ssh_config)
        when /(単位|たんい)/ then @function.get_gacha_result(contents, twitter_id)
        when /(成績|GPA)/ then @function.get_record_text(twitter_id)

        else # どのキーワードにも当てはまらなかったら
          @function.get_response_text(contents, twitter_id)
        end
      rep_text ||= @function.get_response_text(contents, twitter_id)
      return rep_text

    rescue
      error_logs("generate_reply")
    end
  end
end
