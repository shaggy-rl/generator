require 'thread'
require 'socket'
require_relative 'thread-pool.rb'

unless ARGV.length == 2
	puts 'Usage: ruby generator.rb host_address host_ port'
	exit
end

p = Pool.new(30)
host = ARGV[0] 
port = ARGV[1]

socket = TCPSocket.open(host,port)
while 1 == 1 do
	p.schedule do
		socket.puts (1..40).map { (("a".."z").to_a + [" "] * 20)[rand(56)] }.join
	end
end

at_exit { p.shutdown }

