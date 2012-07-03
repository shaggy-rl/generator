require 'thread'
require 'socket'

class Pool
	def initialize(size)
		@size = size
		@jobs = Queue.new
		@pool = Array.new(@size) do |i|
			Thread.new do
				Thread.current[:id] = i
				catch(:exit) do
					loop do
						job, args = @jobs.pop
						job.call(*args)
					end
				end
			end
		end
	end

	def schedule(*args, &block)
		@jobs << [block, args]
	end

	def shutdown
		@size.times do 
			schedule { throw :exit }
		end

		@pool.map(&:join)
	end
end

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

