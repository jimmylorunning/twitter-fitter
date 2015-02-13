class Feed
  include Enumerable
  attr_accessor :feed

  def initialize(raw_feed)
    @feed = []
    add(raw_feed)
  end

  def each(&block)
    @feed.each do |tweet|
      block.call(tweet)
    end
  end

  def add(raw_feed)
    @feed = @feed + clean_feed(raw_feed)
  end

  def clean_feed(raw_feed)
    remove_links(filter_out_crap(raw_feed))
  end

  def filter_out_crap(raw_feed)
    raw_feed.reject do |tweet|
      (tweet.full_text[0] == '@') || (tweet.full_text[0..3] == 'RT @') || (tweet.full_text[1] == '@')
    end
  end

  def remove_links(raw_feed)
    raw_feed.map do |tweet|
      tweet.full_text.gsub(/(https?:[\w|\/|\.|\?|\&]+)/i, '')
    end
  end
end