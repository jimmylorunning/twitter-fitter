class StaticPagesController < ApplicationController
  def home
    @handle1 = params['twitter_handle1']
    @handle2 = params['twitter_handle2']
    return if missing_handles? params
    begin
      generate_tweets(get_feed)
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

  private

  def get_feed
      feed = Feed.new($client.user_timeline(@handle1, :count => 200) + $client.user_timeline(@handle2, :count => 200))
      raise "Sorry, there aren't enough original tweets from those two accounts to combine!" if feed.count < 10
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
    mc = setup_markov_chain(feed)
    10.times { generate_tweet(mc) }
  end

  def generate_tweet(mc)
    t = Tweet.create!(handle1: @handle1, handle2: @handle2, tweet: mc.generate)
    @generated_tweets << { id: t.id, tweet: t.tweet }
  end

  def setup_markov_chain(feed)
    mc = MarkovChain.new :prefix_length => 1
    mc.add_lines feed
    mc
  end
end
