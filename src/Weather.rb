require 'rubygems'
require 'bundler/setup'

require 'net/http'
require 'rexml/document'
require 'pp'

class Weather

  def weather?
    url = 'http://www.drk7.jp/weather/xml/13.xml'
    xml_data = Net::HTTP.get_response(URI.parse(url)).body

    status = {}

    doc = REXML::Document.new(xml_data)
    #today_date = Time.now.strftime('%Y/%m/%d')
    #parse = doc.get_elements("weatherforecast/pref/area[@id=\"東京地方\"]/info[@date=\"#{today_date}\"]/weather")[0].text

    doc.each_element('weatherforecast/pref/area[@id="東京地方"]/info') do |child|
      #p child.attribute('date').to_s
      #p child.elements['weather'].text
      date = child.attribute('date').to_s
      weather = child.elements['weather'].text
      #status[date] = Hash.new('weather' => weather)
      #status[date] = {'weather' => weather}
      status[date] = {'weather' => weather}

      rain_fall_chance = {}
      child.elements['rainfallchance'].each_element do |child|
        #p child.attribute('hour').to_s + ' ' + child.text
        hour = child.attribute('hour').to_s
        value = child.text
        rain_fall_chance[hour] = value
      end
      status[date]['rain_fall_chance'] = rain_fall_chance
    end

    return status
  end

  def get_today_weather
    today_date = Time.now.strftime('%Y/%m/%d')
    return weather?[today_date]
  end
end
