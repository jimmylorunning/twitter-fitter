require 'rails_helper'

RSpec.describe MarkovChain do

  describe "initialize" do
    it "creates a default MarkovChain object when given no parameters" do
    	mc = MarkovChain.new
    	expect(mc._prefix_length).to eq(2)
    	expect(mc._case_insensitive).to eq(true)
    	expect(mc.output_length).to eq(16)
    end

    it "creates a custom MarkovChain object with given parameters" do
    	mc = MarkovChain.new :prefix_length => 3, :output_length => 12
    	expect(mc._prefix_length).to eq(3)
    	expect(mc._case_insensitive).to eq(true)
    	expect(mc.output_length).to eq(12)
    end

    it "raises an error if given invalid prefix length" do
    	expect{
    		MarkovChain.new(:prefix_length => 0)
    	}.to raise_error("Error: prefix_length must be at least 1")
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
	  		expect(@mc.suffix(['it', 'is'])).to eq('not')
	  		expect(@mc.suffix(['it', 'is'])).to eq('and')
	  		expect(@mc.suffix(['it', 'is'])).to eq('not')
	  	end

	  	it "returns suffix based on custom algorithm" do
	  		expect(@mc.suffix(['it', 'is'], lambda { |suffixes| suffixes.last })).to eq('so')
	  		expect(@mc.suffix(['it', 'is'], lambda { |suffixes| suffixes.first })).to eq('what')
	  	end
	  end

  end

  describe "generate" do
  	before(:each) do
  		@mc = MarkovChain.new
  		@mc.add_line 'it is what it is and it is not what it is so not dude ok'
  		@mc.add_line 'sometimes it is just so frustrating when it is difficult'
  	end

  	it "should generate random markov string" do
  		expect(@mc.generate).to eq('it is just so frustrating when it is not what it is and it is so not dude ok')
   		expect(@mc.generate).to eq('it is so not dude ok')
   		expect(@mc.generate).to eq('sometimes it is and it is what it is and it is what it is what it is and it is so not dude ok')
  	end
  end


  describe "reset" do
  	before(:each) do
  		@mc = MarkovChain.new
  		@mc.add 'hello'
  		@mc.add 'world'
  	end

  	it "should start with empty prefix next time it adds a word" do
  		@mc.reset
  		@mc.add 'howdy'
  		chain = {['',''] => ['hello', 'howdy'],
  			['','hello'] => ['world']}
  		expect(@mc._chain).to eq(chain)
  	end
  end

  # new_suffix is a private class. REMOVE this test if it gives you any problems.
  describe "_new_suffix" do
  	it "should generate an array of _prefix_length empty strings" do
  		mc = MarkovChain.new
  		expect(mc._new_suffix).to eq(['', ''])
  		mc = MarkovChain.new :prefix_length => 7
  		expect(mc._new_suffix).to eq(['','','','','','',''])
  	end
  end

end
