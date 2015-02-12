class StaticPagesController < ApplicationController
  def home
  	# try DATABASE_HULK, spaghetmurakami
		@generated_tweets = []
  	@handle =  params['twitter_handle']
  	@handle2 = params['twitter_handle2']
  	return if (@handle.nil? || @handle.empty? || @handle2.nil? || @handle2.empty?)
  	begin
			feed1 = $client.user_timeline(@handle,  :count => 200)
			feed2 = $client.user_timeline(@handle2, :count => 200)
			feed = filter_out_crap feed1 + feed2
			mc = MarkovChain.new :prefix_length => 1

			feed.each do |tweet|
				tweet = tweet.full_text.gsub(/(https?:[\w|\/|\.|\?|\&]+)/i, '')
				mc.add_line tweet
			end

			10.times {
				@generated_tweets << rt_str + mc.generate
			}
		rescue Exception => e
			flash.now[:error] = e.message
		end
  end

  def tweet
  	@tweet = params['tweet']
  	$client.update(@tweet)
  	render 'home'
  end

### helper methods

	def rt_str
		"RT @#{@handle} & @#{@handle2}: "
	end

	def filter_out_crap feed
		feed.reject do |tweet|
			(tweet.full_text[0] == '@') || (tweet.full_text[0..3] == 'RT @') || (tweet.full_text[1] == '@')
		end
	end

end
