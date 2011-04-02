#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'twitter'

PATH_PREFIX = File.expand_path(File.dirname(__FILE__))
config = YAML.parse(File.read(PATH_PREFIX + "/creds.yml"))

%w{consumer_key consumer_secret access_token access_token_secret}.each do |key|
  Object.const_set(key.upcase, config["config"][key].value)
end

URL = PATH_PREFIX + "/schedule.htm"
MINUTE = 60

doc = Nokogiri::HTML(open(URL))

rows = doc.search("table tr")
rows.shift

output = []

rows.each do |row|
  cells = row.search("td")
  timestring = (cells[0].inner_html + " " + cells[1].inner_html + " " + cells[2].inner_html).gsub("&nbsp;", " ")
  time = Time.parse(timestring)
  vessel = cells[3].inner_html
  direction_of_vessel = cells[4].inner_html.downcase
  unless direction_of_vessel.match?("stream")
    direction_of_vessel = direction_of_vessel + "stream"
  end
  output << {:vessel => vessel, :action => "opening", :time => (time - 5*MINUTE), :direction_of_vessel => direction_of_vessel}
  output << {:vessel => vessel, :action => "closing", :time => (time + 5*MINUTE), :direction_of_vessel => direction_of_vessel}
end

next_event = output.select {|event| event[:time] <= (Time.now + MINUTE) and event[:time] >= Time.now}.first

if next_event
  output = ""
  case next_event[:action]
  when "opening"
    output = "I am opening for the #{next_event[:vessel]}"
    if ["maintenance lift", "Maint Lift"].include?(next_event[:vessel].strip.downcase)
      output << "."
    else
      output << ", which is passing #{next_event[:direction_of_vessel]}."
    end
  when "closing"
    output = "I am closing after the #{next_event[:vessel]}"
    if ["maintenance lift", "Maint Lift"].include?(next_event[:vessel].strip.downcase)
      output << "."
    else
      output << " has passed #{next_event[:direction_of_vessel]}."
    end
  end
  # for debug purposes:
  # puts output
  
  Twitter.configure do |config|
    config.consumer_key = CONSUMER_KEY
    config.consumer_secret = CONSUMER_SECRET
    config.oauth_token = ACCESS_TOKEN
    config.oauth_token_secret = ACCESS_TOKEN_SECRET
  end

  Twitter.update(output)
end
