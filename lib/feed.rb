class Feed
  include Enumerable
  attr_accessor :feed

  def initialize(raw_feed=nil)
    @feed = []
    unless raw_feed.nil?
      process_feed raw_feed
    end
  end

  def each(&block)
    @feed.each do |tweet|
      block.call(tweet[:tweet])
    end
  end

  def process_feed(raw_feed)
    add raw_feed
    clean
  end

  private

  def add(raw_feed)
    @feed = @feed + raw_feed
  end

  def clean
    filter_out_crap!
    remove_links!
  end

  def filter_out_crap!
    @feed = @feed.reject do |tweet|
      (tweet[:tweet][0] == '@') || (tweet[:tweet][0..3] == 'RT @') || (tweet[:tweet][1] == '@')
    end
  end

  def remove_links!
    @feed = @feed.map do |tweet|
      { tweet: tweet[:tweet].gsub(/(https?:[\w|\/|\.|\?|\&]+)/i, '') }
    end
  end
end