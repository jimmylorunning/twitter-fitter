require 'rails_helper'

RSpec.describe Tweet, type: :model do
	describe "create" do
		before {
			@long_tweet = "Geronimo! No idea. Just do what I do: hold tight and pretend it's a plan. There's \
something that doesn't make sense. Let's go and poke it with a stick. Look at me."
	    @t1 = Tweet.create(handle1: 'woeiurwer', handle2: 'iuwerklwe8932', tweet: 'hello world hahhahaha')
	    @t2 = Tweet.create(handle1: 'jekyll', handle2: 'hyde',
	    	tweet: @long_tweet)
		}
		it "should create tweet" do
			expect(Tweet.find_by_handle2('iuwerklwe8932')).not_to be_nil
		end

		it "should add RT text before tweet" do
			expect(Tweet.find_by_tweet('RT @woeiurwer & @iuwerklwe8932: hello world hahhahaha')).not_to be_nil
		end

		it "should make tweet no longer than 140 characters long" do
			truncated_tweet = "RT @jekyll & @hyde: Geronimo! No idea. Just do what I do: hold tight and pretend it's a plan. There's something that doesn't make sense. Let"
			expect(Tweet.find_by_tweet(truncated_tweet)).not_to be_nil
		end
	end
end
