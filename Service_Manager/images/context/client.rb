#!/usr/bin/ruby
require 'socket'

ip = ARGV[1]
port = 3333
command = ARGV[0]

sock = TCPSocket.open(ip, port)
sock.puts command
rep = sock.gets.chop
sock.close
puts rep
