#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'twitter'

PATH_PREFIX = File.expand_path(File.dirname(__FILE__))
config = YAML.parse(File.read(PATH_PREFIX + "/creds.yml"))

%w{consumer_key consumer_secret access_token access_token_secret}.each do |key|
  Object.const_set(key.upcase, config["config"][key].value)
end

URL = PATH_PREFIX + "/schedule.htm"
MINUTE = 60

doc = Hpricot(open(URL))

rows = doc.search("table tr")
rows.shift

output = []

rows.each do |row|
  cells = row.search("td")
  timestring = (cells[0].html + " " + cells[1].html + " " + cells[2].html).gsub("&nbsp;", " ")
  time = Time.parse(timestring)
  vessel = cells[3].html
  direction_of_vessel = cells[4].html.downcase
  output << {:vessel => vessel, :action => "opening", :time => (time - 5*MINUTE), :direction_of_vessel => direction_of_vessel}
  output << {:vessel => vessel, :action => "closing", :time => (time + 5*MINUTE), :direction_of_vessel => direction_of_vessel}
end

next_event = output.select {|event| event[:time] <= (Time.now + MINUTE) and event[:time] >= Time.now}.first

if next_event
  output = ""
  case next_event[:action]
  when "opening"
    output = "I am opening for the #{next_event[:vessel]}"
    if next_event[:vessel].strip.downcase == "maintenance lift"
      output << "."
    else
      output << ", which is passing #{next_event[:direction_of_vessel]}."
    end
  when "closing"
    output = "I am closing after the #{next_event[:vessel]}"
    if next_event[:vessel].strip.downcase == "maintenance lift"
      output << "."
    else
      output << " has passed #{next_event[:direction_of_vessel]}."
    end
  end
  # for debug purposes:
  # puts output
  
  oauth = Twitter::OAuth.new(CONSUMER_KEY, CONSUMER_SECRET)
  oauth.authorize_from_access(ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
  
  client = Twitter::Base.new(oauth)
  client.update(output)
end