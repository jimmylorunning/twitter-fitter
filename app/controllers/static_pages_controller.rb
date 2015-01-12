class StaticPagesController < ApplicationController
  def home
  	# try DATABASE_HULK, spaghetmurakami
		@generated_tweet = ''
  	@handle = params['twitter_handle']
  	return if (@handle.nil? || @handle.empty?)
  	begin
			feed = $client.user_timeline(@handle, :count => 200)
			feed = filter_out_crap feed
			mc = MarkovChain.new :prefix_length => 1

			feed.each do |tweet|
				tweet = tweet.full_text.gsub(/(https?:[\w|\/|\.|\?|\&]+)/i, '')
				mc.add_line tweet
			end

			10.times {
				@generated_tweet = @generated_tweet + mc.generate + ' '
			}
		rescue Exception => e
			flash.now[:error] = e.message
		end
  end

### helper methods

	def filter_out_crap feed
		feed.reject do |tweet|
			(tweet.full_text[0] == '@') || (tweet.full_text[0..3] == 'RT @') || (tweet.full_text[1] == '@')
		end
	end

end
