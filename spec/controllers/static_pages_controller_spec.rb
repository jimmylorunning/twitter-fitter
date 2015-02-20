require 'rails_helper'

RSpec.describe StaticPagesController, :type => :controller do

  describe "GET home" do
    it "returns http success" do
      get :home
      expect(response).to have_http_status(:success)
    end

    it "should make handles available to view" do
    	StaticPagesController.any_instance.stub(:missing_handles?).and_return false
    	StaticPagesController.any_instance.stub(:generate_tweets)
    	StaticPagesController.any_instance.stub(:get_feed)
    	get :home, { :handle1 => 'jimmylocoding', :handle2 => 'jimmylorunning' }
    	assigns(:handle1).should == 'jimmylocoding'
    	assigns(:handle2).should == 'jimmylorunning'
    end

    it "should not return generated tweets if handles are missing" do
    end

  end

end
