#! /usr/bin/env ruby

require "socket"
require "uri"
require "net/http"
require "json"
require "optparse"

$area = "400010"
$weather_api = "https://weather.tsukumijima.net/api/forecast/city"

opt = OptionParser.new
opt.on("-a", "--area AREA", "Area code") { |v| $area = v }
opt.parse!(ARGV)

def server(socket)
  while line = socket.gets
    line.chomp!
    if line == ""
      break
    end

    out = ""

    cmd, path, ver = line.split(" ")
    if cmd == "GET"
      if path == "/"
        uri = URI($weather_api + "/" + $area)
        res = Net::HTTP.get_response(uri)
      else
        uri = URI($weather_api + path)
        res = Net::HTTP.get_response(uri)
      end
      data = JSON.load(res.body)

      if data["error"] == nil
        socket.puts "HTTP/1.1 200 OK"
      else
        socket.puts "HTTP/1.1 400 Bad Request"
      end
      socket.puts "Content-Type: application/json"
      socket.puts ""
      socket.puts res.body
    end
  end
  socket.close
end

s0 = TCPServer.open(80)

while true
  sock = s0.accept
  Thread.new do
    server sock
  end
end
