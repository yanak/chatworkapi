require 'chatwork'
require_relative 'Weather'

class API
  API_KEY = ''
  UID = ''

  def initialize
    @weather = Weather.new
  end

  def notice_weather
    weather = today_weather

    message = <<-EOS
[info][title] Today's Weather[/title]
今日の天気
    Abstract: #{weather['weather']}

Rain Fall Chance
    00-06: #{weather['rain_fall_chance']['00-06']}
    06-12: #{weather['rain_fall_chance']['06-12']}
    12-18: #{weather['rain_fall_chance']['12-18']}
    18-24: #{weather['rain_fall_chance']['18-24']}
[/info]
    EOS

    ChatWork.api_key = API_KEY
    ChatWork::Message.create(room_id: 12407368, body: "#{message}")
  end

  def weekly_weather
    @weather.weather?
  end

  private

  def today_weather
    @weather.get_today_weather
  end

  def fall_rain?

  end

end

api = API.new
#api.notice_weather
#p api.today_weather
p api.weekly_weather
