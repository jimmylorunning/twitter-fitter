class MarkovChain

	attr_accessor :output_length		# max number of words that will be generated

	# private variables
	attr_accessor :_prefix_length
	attr_accessor :_case_insensitive
	attr_accessor :_last_prefix
	attr_accessor :_last_suffix
	attr_accessor :_chain

	# constants
	LINE_ENDINGS = ['.', '!', '?']

	def initialize(options = {})
		@_prefix_length = options[:prefix_length] || 2
		raise "Error: prefix_length must be at least 1" if @_prefix_length < 1
		@_last_prefix = Array.new(@_prefix_length, '')
		@_last_suffix = ''
		@_chain = Hash.new
		@output_length = options[:output_length] || 26
		@_case_insensitive = options[:case_insensitive].nil? ? true : options[:case_insensitive]
	end

	def add(word)
			self.new_line if (LINE_ENDINGS.include? self._last_suffix[-1])
			self._last_prefix = self._next_prefix
			self._last_suffix = word
			if self._chain[self._last_prefix]
				self._chain[self._last_prefix] = self._chain[self._last_prefix] << word
			else
				self._chain[self._last_prefix] = [word]
			end
	end

	def add_line(line)
		self.new_line
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
		generated, length_counter = Array.new, 0
		prefix = self._new_prefix
		while ((new_word = self.suffix(prefix, generator)) && (length_counter < self.output_length))
			prefix = self._next_prefix(prefix, new_word)
			generated << new_word
			length_counter += 1
		end
		generated.join(' ')
	end

	# new_line allows you to start again with the default suffix next time you add [a] word(s)
	def new_line
		self._last_prefix = self._new_prefix
		self._last_suffix = ''
	end

	def _new_prefix
		Array.new(self._prefix_length, '')
	end

	# returns the next prefix given prefix & suffix (which defaults to last prefix & suffix)
	def _next_prefix(prefix=self._last_prefix, suffix=self._last_suffix)
		suffix = suffix.downcase if self._case_insensitive === true
		prefix.slice(1..-1) << suffix
	end

end