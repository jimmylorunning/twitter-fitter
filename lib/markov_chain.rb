class MarkovChain

  attr_accessor :output_length    # max number of words that will be generated

  # private variables
  attr_accessor :_prefix_lengths
  attr_accessor :_case_insensitive
  attr_accessor :_last_prefixes
  attr_accessor :_last_suffix
  attr_accessor :_chain

  # constants
  LINE_ENDINGS = ['.', '!', '?']
  PREFIX_LENGTH_ERROR = "All elements of prefix_lengths must be at least 1" 

  def initialize(options = {})
    self.output_length = options[:output_length] || 26
    self._case_insensitive = options[:case_insensitive].nil? ? true : options[:case_insensitive]
    self._prefix_lengths = options[:prefix_lengths] || [2]
    raise ArgumentError, PREFIX_LENGTH_ERROR if self._prefix_lengths.any? { |pl| pl < 1 }
    self.new_line
    self._chain = Hash.new
  end

  def add(word)
    self.new_line if (LINE_ENDINGS.include? self._last_suffix[-1])
    self._last_prefixes = self._advance_prefixes
    self._last_suffix = word
    self._last_prefixes.each do |prefix|
      if self._chain[prefix]
        self._chain[prefix] = self._chain[prefix] << word
      else
        self._chain[prefix] = [word]
      end
    end
  end

  def add_line(line)
    self.new_line
    line.split.each do |word|
      self.add word
    end
  end

  def add_lines(lines)
    lines.each do |line|
      add_line(line)
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
    prefixes = self._new_prefixes
    while ((new_word = self.suffix(prefixes.sample, generator)) && (length_counter < self.output_length))
      prefixes = self._advance_prefixes(prefixes, new_word)
      generated << new_word
      length_counter += 1
    end
    generated.join(' ')
  end

  # new_line allows you to start again with the default suffix next time you add [a] word(s)
  def new_line
    self._last_prefixes = self._new_prefixes
    self._last_suffix = ''
  end

  def _new_prefixes
    prefixes = []
    self._prefix_lengths.each do |len|
      prefixes << Array.new(len, '')
    end
    prefixes
  end

  def _advance_prefixes(prefixes=self._last_prefixes, suffix=self._last_suffix)
    return prefixes.map do |prefix|
      suffix = suffix.downcase if self._case_insensitive === true
      prefix.slice(1..-1) << suffix
    end
  end

end
