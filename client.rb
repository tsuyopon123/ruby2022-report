#! /usr/bin/env ruby

require "uri"
require "net/http"
require "json"
require "optparse"

area = nil
server_addr = "localhost"

opt = OptionParser.new
opt.on("-a", "--area AREA", "Area code") { |v| area = v }
opt.on("-s", "--server SERVER", "Server address") { |v| server_addr = v }
opt.parse!(ARGV)

uri = URI("http://#{server_addr}/#{area}")
res = Net::HTTP.get_response(uri)

if res.code == "200"
  data = JSON.load(res.body)
  puts "#{data["title"]} (#{data["description"]["publicTimeFormatted"]}発表)"
  puts
  puts "概要: #{data["description"]["text"].gsub(/\n/, "").gsub("　", "")}"
  puts

  data["forecasts"].each do |forecast|
    puts "#{forecast["dateLabel"]}(#{forecast["date"]}): #{forecast["telop"]}"
    puts "  最高気温: #{forecast["temperature"]["max"]["celsius"]}℃"
    puts "  最低気温: #{forecast["temperature"]["min"]["celsius"]}℃"
  end

  # puts data
else
  puts "Error"
end
