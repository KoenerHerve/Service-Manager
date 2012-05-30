require 'socket'
require 'ping'


class ClientTCP

	# ClientTCP.execute
	# Execute a bash script on a host
	# ip: _String_ Ip of the host where to execute the script
	# commands: _String_ The script
	def ClientTCP.execute(ip, script)
		port = 3333

		script=script.gsub(Regexp.new('\\\\'), '\\\\\\')
		script=script.gsub(Regexp.new('\\n'), '\\n')

		sock = TCPSocket.open(ip, port)
		sock.puts script
		#while line = sock.gets
		#	Log.info line.chop
		#end
		Log.info sock.gets.chop
		sock.close
	end

end
