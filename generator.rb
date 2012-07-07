require 'thread'
require 'socket'
require_relative 'thread-pool.rb'
require_relative 'markov-chains.rb'

# Ussage statement and check for proper number of command line arguments

unless ARGV.length > 6
	puts 'Usage: ruby generator.rb host_address host_ port number_threads order number_of_sentences input_file'
	puts 'Can have multiple input_files'
	exit
end

# initiate all variables

p = Pool.new(ARGV[2].to_i)
host = ARGV[0] 
port = ARGV[1]
order = ARGV[3].to_i
number_sentences = ARGV[4].to_i
socket = TCPSocket.open(host,port)

# shift the command line arguments off the array to be able to use ARGF
# to read in the file for the dictionary 

5.times {
	ARGV.shift
}

# Create a Markov Chain

markov = MarkovChainer.new(order)

# Create a new thread to read in the file to create dictionary 

markov.add_text(ARGF.read)

# Schedule threads from the thread pool to 
# generate sentences and sent them to the target 
# listening host

number_sentences.times {
	p.schedule do
		socket.puts markov.generate_sentence
	end
}

	
# Depracated random sentence code
#while 1 == 1 do
#	p.schedule do
#		socket.puts (1..40).map { (("a".."z").to_a + [" "] * 20)[rand(56)] }.join
#	end
#end

at_exit { p.shutdown }

