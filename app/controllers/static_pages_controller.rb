class StaticPagesController < ApplicationController
  def home
		@generated_tweets = []
  	@handle1 = params['twitter_handle1']
  	@handle2 = params['twitter_handle2']
  	return if (@handle1.nil? || @handle1.empty? || @handle2.nil? || @handle2.empty?)
  	begin
			feed = Feed.new($client.user_timeline(@handle1, :count => 200) + $client.user_timeline(@handle2, :count => 200))
			mc = MarkovChain.new :prefix_length => 1

			feed.each do |tweet|
				mc.add_line tweet
			end

			10.times {
				t = Tweet.create!(handle1: @handle1, handle2: @handle2, tweet: mc.generate)
				@generated_tweets << { id: t.id, tweet: t.tweet }
			}
		rescue Exception => e
			flash.now[:error] = e.message
		end
  end

  def tweet
  	@handle1 = params['handle1']
  	@handle2 = params['handle2']
  	tweet = Tweet.find_by_id(params['tweet_id'].to_i)
  	@tweet = tweet.tweet
  	$client.update(@tweet)
  	render 'home'
  end

end
