class StaticPagesController < ApplicationController
  def home
		@jlc = $client.user_timeline('jimmylocoding', count: 25)
# jlr.each { |tweet| ... }
  end
end
