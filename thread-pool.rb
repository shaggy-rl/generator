# This code was found http://burgestrand.se/code/ruby-thread-pool/
# Decided to use this pool implementation then creating my own

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

