#!/usr/bin/ruby
require 'socket'

port = 3333
server = TCPServer.new(port)
loop do
	Thread.start(server.accept) do |client|
		system("echo '#! /bin/bash' > /servman/cmd.sh")
		while line = client.gets
			command = line.chop
			system("echo '"+command+"' >> /servman/cmd.sh")
			rep = IO.popen("/servman/cmd.sh").readlines
			client.puts(rep)
		end
		client.close
	end
end
