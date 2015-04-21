require 'rails_helper'

RSpec.describe MarkovChain do

  describe "initialize" do
    it "creates a default MarkovChain object when given no parameters" do
    	mc = MarkovChain.new
    	expect(mc._prefix_length).to eq([2])
    	expect(mc._case_insensitive).to eq(true)
    	expect(mc.output_length).to eq(26)
    end

    it "creates a custom MarkovChain object with given parameters" do
    	mc = MarkovChain.new :prefix_length => [3], :output_length => 12
    	expect(mc._prefix_length).to eq([3])
    	expect(mc._case_insensitive).to eq(true)
    	expect(mc.output_length).to eq(12)
      mc2 = MarkovChain.new :case_insensitive => false
      expect(mc2._case_insensitive).to eq(false)
    end

    it "raises an error if given invalid prefix length" do
    	expect{
    		MarkovChain.new(:prefix_length => [0, 1])
    	}.to raise_error(ArgumentError)
    end
  end

  describe "add" do
  	before(:each) { @mc = MarkovChain.new }

  	it "adds new prefix => suffix if prefix not found" do
  		@mc.add 'i'
  		chain = {['',''] => ['i']}
  		expect(@mc._chain).to eq(chain)
  		@mc.add 'am'
  		chain[['', 'i']] = ['am']
  		expect(@mc._chain).to eq(chain)
  	end

  	it "adds new suffix possibilities to existing prefix" do
  		@mc.add 'i'
  		@mc.add 'am'
  		@mc.add 'i'
  		@mc.add 'am'
  		chain = {['',''] => ['i'],
  			['','i'] => ['am'],
  			['i', 'am'] => ['i'],
  			['am', 'i'] => ['am']}
  		expect(@mc._chain).to eq(chain)
  		@mc.add 'sam'
  		chain[['i', 'am']] = ['i', 'sam']
  		expect(@mc._chain).to eq(chain)
  	end

    it "should be case insensitive if flag set" do
      @mc.add 'i'
      @mc.add 'am'
      @mc.add 'I'
      @mc.add 'AM'
      chain = {['',''] => ['i'],
        ['','i'] => ['am'],
        ['i', 'am'] => ['I'],
        ['am', 'i'] => ['AM']}
      expect(@mc._chain).to eq(chain)
      @mc.add 'sam'
      chain[['i', 'am']] = ['I', 'sam']
      expect(@mc._chain).to eq(chain)
    end

    it "should be case sensitive if flag not set" do
      @mc = MarkovChain.new :case_insensitive => false
      expect(@mc._case_insensitive).to eq(false)
      @mc.add 'i'
      @mc.add 'am'
      @mc.add 'I'
      @mc.add 'AM'
      chain = {['',''] => ['i'],
        ['','i'] => ['am'],
        ['i', 'am'] => ['I'],
        ['am', 'I'] => ['AM']}
      expect(@mc._chain).to eq(chain)
      @mc.add 'sam'
      chain[['I', 'AM']] = ['sam']
      expect(@mc._chain).to eq(chain)
    end

    it "should add newline if new word ends a sentence" do
      @mc.add 'hello'
      @mc.add 'world.'
      @mc.add 'goodbye'
      chain = {['',''] => ['hello', 'goodbye'],
        ['','hello'] => ['world.']}
      expect(@mc._chain).to eq(chain)
    end
  end

  describe "add_line" do
  	before(:each) { @mc = MarkovChain.new }

  	it "adds new chain for entire line" do
  		@mc.add_line 'i am i am sam'
  		chain = {['',''] => ['i'],
  			['','i'] => ['am'],
  			['i', 'am'] => ['i', 'sam'],
  			['am', 'i'] => ['am']}
  		expect(@mc._chain).to eq(chain)
  	end

  	it "resets to empty prefixes after every line" do
   		@mc.add_line 'i am i am sam'
   		@mc.add_line 'hello world'
  		chain = {['',''] => ['i', 'hello'],
  			['','hello'] => ['world'],
  			['','i'] => ['am'],
  			['i', 'am'] => ['i', 'sam'],
  			['am', 'i'] => ['am']}
  		expect(@mc._chain).to eq(chain)
  	end

    it "should add short sentences correctly" do
      @mc.add_line 'hello. world! i am?'
      @mc.add_line 'my name? jimmy lo.'
      chain = {['', ''] => ['hello.', 'world!', 'i', 'my', 'jimmy'],
        ['', 'i'] => ['am?'],
        ['', 'my'] => ['name?'],
        ['', 'jimmy'] => ['lo.']}
      expect(@mc._chain).to eq(chain)
    end
  end

  describe "suffix" do
  	before(:each) do
  		@mc = MarkovChain.new
  		@mc.add_line 'it is what it is and it is not what it is so not dude ok'
  	end

  	context "when there is just one possible suffix" do
	  	it "returns that suffix" do
	  		expect(@mc.suffix(['not', 'dude'])).to eq('ok')
	  	end
  	end

  	context "when there are more than one possibilities" do
	  	it "returns one of many possible suffixes" do
	  		# seed specified in spec_helper
	  		expect(@mc.suffix(['it', 'is'])).to eq('and')
	  		expect(@mc.suffix(['it', 'is'])).to eq('not')
	  		expect(@mc.suffix(['it', 'is'])).to eq('not')
	  	end

	  	it "returns suffix based on custom algorithm" do
	  		expect(@mc.suffix(['it', 'is'], lambda { |suffixes| suffixes.last })).to eq('so')
	  		expect(@mc.suffix(['it', 'is'], lambda { |suffixes| suffixes.first })).to eq('what')
	  	end

      it "returns suffix without regard to case if case insensitive flag set" do
        @mc.add_line 'IT IS WHAT IT IS AND IT IS NOT WHAT IT IS SO NOT DUDE OK'
        expect(@mc.suffix(['it', 'is'], lambda {|suffixes| suffixes})).to eq(['what', 'and', 'not', 'so', 'WHAT', 'AND', 'NOT', 'SO'])
      end
	  end

  end

  describe "generate" do
  	it "should generate random markov string" do
      mc = MarkovChain.new
      mc.add_line 'it is what it is and it is not what it is so not dude ok'
      mc.add_line 'sometimes it is just so frustrating when it is difficult'

  		expect(mc.generate).to eq('it is not what it is and it is so not dude ok')
   		expect(mc.generate).to eq('it is so not dude ok')
   		expect(mc.generate).to eq('sometimes it is and it is what it is and it is what it is what it is and it is so not dude ok')
  	end

    it "should generate a string within the output length number of words" do
      mc = MarkovChain.new
      mc.add_line 'it is it is'
      expect(mc.generate).to eq(Array.new(13, 'it is').join(' '))
      mc2 = MarkovChain.new :output_length => 2
      mc2.add_line 'it is it is'
      expect(mc2.generate).to eq('it is')
    end

    it "should generate random markov string -- case insensitive" do
      mc = MarkovChain.new :case_insensitive => true
      mc.add_line 'IT is what iT iS and It Is not what iT Is so not dude ok'
      mc.add_line 'sometimes it IS just so frustrating when IT is difficult'

      expect(mc._case_insensitive).to eq(true)
      expect(mc.generate).to eq('IT is difficult')
      expect(mc.generate).to eq('IT is what iT iS just so frustrating when IT is and It Is so not dude ok')
      expect(mc.generate).to eq('IT is just so frustrating when IT is not what iT iS what iT Is what iT Is and It Is so not dude ok')
    end

    it "should generate random markov string -- case sensitive" do
      mc = MarkovChain.new :case_insensitive => false
      mc.add_line 'IT is what iT iS and It Is not what iT Is so not dude ok'
      mc.add_line 'IT is sometimes it IS just so frustrating when IT is difficult'

      expect(mc._case_insensitive).to eq(false)
      expect(mc.generate).to eq('IT is what iT iS and It Is not what iT Is so not dude ok')
      expect(mc.generate).to eq('IT is difficult')
      expect(mc.generate).to eq('IT is sometimes it IS just so frustrating when IT is what iT iS and It Is not what iT Is so not dude ok')
    end

  end

  describe "new_line" do
  	before(:each) do
  		@mc = MarkovChain.new
  		@mc.add 'hello'
  		@mc.add 'world'
  	end

  	it "should start with empty prefix next time it adds a word" do
  		@mc.new_line
  		@mc.add 'howdy'
  		chain = {['',''] => ['hello', 'howdy'],
  			['','hello'] => ['world']}
  		expect(@mc._chain).to eq(chain)
  	end
  end

  # new_prefix is a private class. REMOVE this test if it gives you any problems.
  describe "_new_prefixes" do
  	it "should generate an array of arrays of empty strings, one empty array for each prefix_length" do
  		mc = MarkovChain.new
  		expect(mc._new_prefixes).to eq([['', '']])
  		mc = MarkovChain.new :prefix_length => [7]
  		expect(mc._new_prefixes).to eq([['','','','','','','']])
  	end
  end

end
