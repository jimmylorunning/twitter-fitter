$client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['twitter_consumer_key']
  config.consumer_secret     = ENV['twitter_consumer_secret']
  config.access_token        = ENV['twitter_access_token']
  config.access_token_secret = ENV['twitter_access_token_secret']
end

# example of printing out my most recent tweets:
# timeline = $client.user_timeline
# timeline.each { |tweet| puts tweet.full_text }

# or to get another user
# jlr = $client.user_timeline('jimmylorunning', count: 100)
# jlr.each { |tweet| ... }