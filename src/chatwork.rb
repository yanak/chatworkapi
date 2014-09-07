require 'net/https'
require 'zlib'
require 'uri'
require 'json'
require 'pp'

class Chat

  def initialize
    @base_url = 'kcw.kddi.ne.jp'
    @login_url = ''
    @get_url = 'gateway.php'
    @account = ''
    @mail = ''
    @password = ''
    @cookie_ = ''
    @access_token_ = ''
    @https_ = create_https

    @post_header_ = {
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Encoding' => 'gzip,deflate',
        'Accept-Language' => 'ja,en-US;q=0.8',
        'Cache-Control' => 'no-cache',
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Pragma' => 'no-cache',
        'Origin' => 'https://kcw.kddi.ne.jp',
        'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.94 Safari/537.36',
    }

    @get_header_ = {
        'Accept' => 'application/json, text/javascript, */*; q=0.01',
        'Accept-Encoding' => 'UTF-8,gzip,deflate,sdch',
        'Accept-Language' => 'ja,en-US;q=0.8',
        'Cache-Control' => 'no-cache',
        'Pragma' => 'no-cache',
        'Referer' => 'https://kcw.kddi.ne.jp/',
        'Content-Type' => 'text/html; charset=utf-8',
        'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.94 Safari/537\'.36',
        #'X-NewRelic-ID' => 'VwYDUFBbGwEIUVFUAwE=',
        #'X-Requested-With' => 'XMLHttpRequest',
    }
  end

  def connect
    @get_header_['Cookie'] = cookie
    @access_token_ = access_token
  end

  # retrieve my chat list
  # @param [Int] from the retrieve second that between a latest message and old messages
  #
  def chat_list(from = 10)
    uri = "/#{@get_url}?cmd=load_chat&myid=712724&_v=1.80a&_av=4&_t=#{@access_token_}&ln=ja&room_id=12407368&last_chat_id=0&first_chat_id=0&jump_to_chat_id=0&unread_num=0&file=1&task=1&desc=1&_=1409976119945"
    lists = []
    @https_.start do
      body = @https_.get(uri, @get_header_).body
      StringIO.open(body, 'rb') do |sio|
        content = Zlib::GzipReader.wrap(sio).read
        lists = JSON.load(content)['result']['chat_list']
      end
    end

    new_message = []
    lists.each do |list|
      if list['tm'] >= Time.now.to_i - 10
        new_message << list
      end
    end

    return new_message
  end

  private

  def create_https
    https = Net::HTTP.new(@base_url, 443)
    https.use_ssl = true
    https.ca_file = '../ca/cacert.pem'
    https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    https.verify_depth = 5

    return https
  end

  def cookie
    response = ''
    @https_.start do
      #p https.head '/login.php?lang=ja&s=h', "email=#{@mail}&password=#{@password}&login=ログイン"
      #response = https.post('/login.php?lang=ja&s=', "email=#{@mail}&password=#{@password}&login=ログイン")
      response = @https_.post('/login.php?lang=ja&s=', "email=&password=&login=%E3%83%AD%E3%82%B0%E3%82%A4%E3%83%B3", @post_header_)
    end

    fields = response.get_fields('Set-Cookie').map do |field|
      /(cwssid=\w+|AWSELB=\w+)/.match(field)[1]
    end

    sessions = []
    fields.uniq.each do |field|
      kv = field.split('=')
      sessions << {kv[0] => kv[1]}
    end

    cwssid = ''
    awselb = ''
    sessions.each do |session|
      session.each do |key, value|
        if key == 'cwssid'
          cwssid = key + '=' + value + ';'
        elsif key == 'AWSELB'
          awselb = key + '=' + value + ';'
        end
      end
    end
    cookie = cwssid + ' ' + awselb

    return cookie
  end

  def access_token
    token = ''
    @https_.start do
      body = @https_.get('/', @get_header_).body
      StringIO.open(body, 'rb') do |sio|
        content = Zlib::GzipReader.wrap(sio).read
        token = /ACCESS_TOKEN = '(\w+)'/.match(content)[1]
      end
    end

    return token
  end

end

c = Chat.new
c.connect
c.chat_list
(1..10).each do |i|
  pp c.chat_list
  p i.to_s + ' times'
  sleep(10)
end
