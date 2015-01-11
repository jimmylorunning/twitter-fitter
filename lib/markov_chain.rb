class MarkovChain

	attr_accessor :output_length		# max number of words that will be generated

	# private variables
	attr_accessor :_prefix_length
	attr_accessor :_case_insensitive
	attr_accessor :_last_prefix
	attr_accessor :_last_suffix
	attr_accessor :_chain

	def initialize(options = {})
		@_prefix_length = options[:prefix_length] || 2
		raise "Error: prefix_length must be at least 1" if @_prefix_length < 1
		@_last_prefix = Array.new(@_prefix_length, '')
		@_last_suffix = ''
		@_chain = Hash.new
		@_case_insensitive = options[:case_insensitive] || true # doesn't work yet
		@output_length = options[:output_length] || 16 # doesn't work yet
	end

	def add(word)
			self._last_prefix= self._last_prefix.slice(1..-1) << self._last_suffix
			self._last_suffix = word
			if self._chain[self._last_prefix]
				self._chain[self._last_prefix] = self._chain[self._last_prefix] << word
			else
				self._chain[self._last_prefix] = [word]
			end
	end

	def add_line(line)
		self.reset
		line.split.each do |word|
			self.add word
		end
	end

	# generates the suffix randomly by default
	def suffix(prefix, generator=lambda { |suffixes| suffixes[Random.rand(suffixes.length)] } )
		if self._chain[prefix]
			generator.call(self._chain[prefix])
		end
	end

	def generate( generator=lambda { |suffixes| suffixes[Random.rand(suffixes.length)] } )
		generated = Array.new
		suffix = self._new_suffix
		while new_word = self.suffix(suffix, generator)
			suffix << new_word
			suffix.shift
			generated << new_word
		end
		generated.join(' ')
	end

	# reset starts again with the default suffix
	# it does not remove the existing chain data, but allows you to add a new sentence
	def reset
		self._last_prefix = self._new_suffix
		self._last_suffix = ''
	end

	def _new_suffix
		Array.new(self._prefix_length, '')
	end

end