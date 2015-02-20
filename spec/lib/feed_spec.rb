require 'rails_helper'

RSpec.describe Feed do

	describe "initialize" do
		context "without initial feed" do
			it "sets the feed to empty array" do
				f = Feed.new
				expect(f.feed).to eq []
			end
		end
		context "with initial feed" do
			it "calls process_feed" do
				# not sure how to do this
			end
		end
	end

	describe "each" do
		before {
			raw_feed =
				[ { tweet: "Hello world" },
					{ tweet: "Cowabunga! Something something"},
					{ tweet: "I don't know what to say here"} ]
			@f = Feed.new(raw_feed)
		}

		it "should iterate through each tweet" do
			tweet_array = []
			@f.each do |t|
				tweet_array << t
			end
			expect(tweet_array).to eq ["Hello world",
				"Cowabunga! Something something",
				"I don't know what to say here"]
		end
	end

	describe "process_feed" do
		before {
			@f = Feed.new
			raw_feed =
				[ { tweet: "Normal tweet" },
					{ tweet: "RT @someone retweet" },
					{ tweet: "@bobby good day, sir!"},
					{ tweet: ".@kimmy is my best friend" },
					{ tweet: "Another plain ol tweet" },
					{ tweet: "hey visit my website please http://www.google.com" }
				]
			@f.process_feed(raw_feed)
		}

		it "removes retweets, personal tweets, and links" do
			expect(@f.feed).to eq [ { tweet: "Normal tweet" },
				{ tweet: "Another plain ol tweet" },
				{ tweet: "hey visit my website please " } ]
		end

	end

end
