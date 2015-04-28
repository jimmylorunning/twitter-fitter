class StaticPagesController < ApplicationController

  class InsufficientDataError < StandardError; end
  class TweetNotFoundError < StandardError; end

  before_filter :set_handles, :only => [:home, :tweet]

  INSUFFICIENT_DATA_ERROR = "Sorry, there aren't enough original tweets from those two accounts to combine!"
  TWEET_NOT_FOUND_ERROR = "Sorry that tweet has expired or can't be found."

  def home
    return if missing_handles? params
    begin
      generate_tweets get_feed
    rescue Twitter::Error => e
      flash.now[:error] = "Twitter error: #{e.message}"
    rescue StaticPagesController::InsufficientDataError => e
      flash.now[:error] = e.message
    end
  end

  def tweet
    begin
      send_tweet params[:tweet_id]
    rescue StaticPagesController::TweetNotFoundError => e
      flash.now[:error] = e.message
    end
    render 'home'
  end

  private

  def set_handles
    @handle1 = params['twitter_handle1'] || params['handle1']
    @handle2 = params['twitter_handle2'] || params['handle2']
  end

  def get_feed
      @twitter = TwitterWrapper.new $client
      feed = Feed.new(@twitter.get_timeline(@handle1) + @twitter.get_timeline(@handle2))
      raise StaticPagesController::InsufficientDataError, INSUFFICIENT_DATA_ERROR if feed.count < 10
      feed
  end

  def missing_handles?(params)
    params['twitter_handle1'].nil? ||
      params['twitter_handle1'].empty? ||
      params['twitter_handle2'].nil? ||
      params['twitter_handle2'].empty?
  end

  def generate_tweets(feed)
    @generated_tweets = []
    mc = setup_markov_chain feed
    10.times { generate_tweet mc }
  end

  def generate_tweet(mc)
    t = Tweet.create(handle1: @handle1, handle2: @handle2, tweet: mc.generate)
    @generated_tweets << { id: t.id, tweet: t.tweet }
  end

  def setup_markov_chain(feed)
    mc = MarkovChain.new :prefix_lengths => [1, 2]
    mc.add_lines feed
    mc
  end

  def send_tweet(tweet_id)
    tweets = Tweet.where("id = #{tweet_id.to_i} AND created_at > '#{get_time_limit}'")
    raise StaticPagesController::TweetNotFoundError, TWEET_NOT_FOUND_ERROR if tweets.empty?
    @tweet = tweets.first.tweet
    @twitter = TwitterWrapper.new $client
    @twitter.tweet @tweet
  end

  def get_time_limit
    (Time.now - (60 * 10)).in_time_zone("UTC").to_s
  end
end
