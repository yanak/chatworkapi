require 'rubygems'
require 'bundler/setup'

require 'net/http'
require 'rexml/document'
#require 'nokogiri/xml'

class Weather

  def weather?
    url = 'http://www.drk7.jp/weather/xml/13.xml'
    xml_data = Net::HTTP.get_response(URI.parse(url)).body

    doc = REXML::Document.new(xml_data)
    parse = doc.get_elements('weatherforecast/pref/area[@id="東京地方"]/info[@date="2014/08/18"]/weather')[0].text

  end

end

weather = Weather.new
p weather.weather?