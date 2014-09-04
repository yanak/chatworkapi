require 'net/https'

class Chat

  def initialize
    @base_url = 'kcw.kddi.ne.jp'
    @login_url = ''
    @account = ''
    @password = ''
  end

  def connect
    # Net::HTTP.start(base_url) do |http|
    #   req = Net::HTTP::Get.new(login_url)
    #   req.basic_auth account, password
    #   response = http.request(req)
    #   p response

    https = Net::HTTP.new(@base_url, 443)
    https.use_ssl = true
    https.ca_file = '../ca/cacert.pem'
    https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    https.verify_depth = 5
    https.start do
      response = https.get('/login.php')
      #p response.body
      File.open('../resource/body', 'w') do |file|
        file.write(response.body)
      end
    end
  end

end

c = Chat.new
c.connect