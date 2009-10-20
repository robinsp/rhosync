require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe App do
  before(:each) do
    @valid_attributes = {:name => "BigEnterprise"}
  end

  it "should create a new instance given valid attributes" do
    App.create!(@valid_attributes)
  end

  describe "responding to subscribe and unsubscribe" do
    it "should add a membership when subscribe is called"
  end

  describe "application level authentication" do
    before(:each) do
      App.destroy_all
      User.destroy_all

      @app = App.create(:name => "TestWithAuthentication")
    end

    it "responds to authenticate if developer has defined" do
      @app.authenticates?.should be_true
    end

    it "does not respond to authenticate if developer has not defined" do
      @app = App.new(:name => "TestWithoutAuthentication")
      @app.authenticates?.should_not be_true
    end

    it "creates new user if a new user authenticates" do
      @app.delegate.should_receive(:authenticate).and_return(true)

      lambda {
        @app.authenticate("user@remedy.com", "password", nil)
      }.should change(User, :count).by(1)
    end

    it "subscribes new user if a new user authenticates" do
      @app.delegate.should_receive(:authenticate).and_return(true)

      @user = @app.authenticate("user@remedy.com", "password", nil)
      @app.users.should include(@user)
    end

    it "does not create new user if new user fails to authenticate" do
      @app.delegate.should_receive(:authenticate).and_return(false)

      lambda {
        @app.authenticate("user@remedy.com", "password", nil)
      }.should_not change(User, :count)
    end

    describe "existing users" do
      before(:each) do
        @user = User.create(:login => "existing@remedy.com", :password => "doesnotmatter", :password_confirmation => "doesnotmatter")
        @app.users << @user
      end

      it "passes login of an existing user if authentication is good" do
        @app.delegate.should_receive(:authenticate).and_return(true)
        @app.authenticate("existing@remedy.com", "password", nil).should == @user
      end

      it "rejects login of an existing user if authentication now fails" do
        @app.delegate.should_receive(:authenticate).and_return(false)
        @app.authenticate("existing@remedy.com", "password", nil).should be_nil
      end
    end
    
    describe "administrators" do
      def create_administration(app, user)
        Administration.create!(:app => app, :user => user)
      end
      
      it "should find the administrators for an application" do 
        rock_band_gear_app = Factory.create(:app, :name => "RockBandGear")
        drummer = Factory.create(:user)
        guitarist = Factory.create(:user)
        create_administration(rock_band_gear_app, drummer)
        create_administration(rock_band_gear_app, guitarist)
        
        news_paper_app = Factory.create(:app, :name => "NewsPapers")
        journalist = Factory.create(:user)
        create_administration(news_paper_app, journalist)
        
        rock_band_gear_app.administrators.should == [drummer, guitarist]
      end
      
    end
  end

end
