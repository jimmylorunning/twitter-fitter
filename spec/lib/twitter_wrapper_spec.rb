require 'rails_helper'

RSpec.describe TwitterWrapper do

	describe "initialize" do
		it "sets the client" do
			tc = double("twitter client")
			tw = TwitterWrapper.new tc
			expect(tw.client).to eq tc
		end
	end

	describe "get_timeline" do
		before do
			@tc = double("twitter client")
			@tw = TwitterWrapper.new @tc
		end

		it "asks the Twitter API for user's timeline" do
			handle = 'jimmy'
			@tc.should_receive(:user_timeline).with(handle, :count => 200).and_return []
			@tw.get_timeline handle
		end

		it "returns array of hashes" do
			tweet1 = double("hello")
			tweet2 = double("world")
			tweet1.stub(:full_text).and_return 'something'
			tweet2.stub(:full_text).and_return 'else'
			timeline = [tweet1, tweet2]
			@tc.stub(:user_timeline).and_return timeline
 	 		expect(@tw.get_timeline('jimmy')).to eq [ {tweet: 'something'}, {tweet: 'else'}]
		end
	end

	describe "tweet" do
		before do
			@tc = double("client")
			@tw = TwitterWrapper.new @tc
		end

		it "asks Twitter to send a tweet" do
			test_tweet = "Hello World"
			@tc.should_receive(:update).with(test_tweet)
			@tw.tweet test_tweet
		end
	end

end
