class Tweet < ActiveRecord::Base


	def self.create!(params)
		@handle1 = params[:handle1]
		@handle2 = params[:handle2]
		params[:tweet] = fix_tweet(params[:tweet])
		super
	end

	def self.fix_tweet(tweet)
		"#{self.rt_str} #{tweet}"[0..139]
	end

	def self.rt_str
		"RT @#{@handle1} & @#{@handle2}:"
	end
end
