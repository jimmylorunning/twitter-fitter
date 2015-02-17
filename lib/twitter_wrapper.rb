class TwitterWrapper

	def initialize(client)
		@client = client
	end

	def get_timeline(handle, count=200)
		timeline = @client.user_timeline(handle, :count => count)
		timeline.map do |tweet|
			{ tweet: tweet.full_text }
		end
	end

	def tweet(tweet)
		@client.update tweet
	end

end