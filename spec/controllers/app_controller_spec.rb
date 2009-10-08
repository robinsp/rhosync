require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AppsController do
  fixtures :apps
  fixtures :users


  before(:each) do
    current_user=login_as(:quentin)
  end

  def mock_app(stubs={})
    basestubs = {:name=>"test",
      :description=>"test description",
      :admin=>'quentin',
      "admin=".to_sym=>'quentin'}
    stubs.merge!(basestubs)
    @adapter = mock_model(Source, stubs)
    @mock_app ||= mock_model(App, stubs)
  end



  describe "responding to GET index" do

    it "should expose all apps as @apps" do
      pending("Test needs to be brought up to date.")
      App.should_receive(:find).with(:all,{:conditions=>{:admin=>"quentin"}}).and_return([mock_app])
      get :index
      assigns[:apps].should == [mock_app]
    end

    describe "with mime type of xml" do

      it "should render all apps as xml" do
        pending("Test needs to be brought up to date.")
        request.env["HTTP_ACCEPT"] = "application/xml"
        App.should_receive(:find).with(:all,{:conditions=>{:admin=>"quentin"}}).and_return(apps = mock("Array of Apps"))
        apps.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end

    end

  end

  describe "responding to GET new" do

    it "should expose a new app as @app" do
      App.should_receive(:new).and_return(mock_app)
      get :new
      assigns[:app].should equal(mock_app)
    end

  end

  describe "responding to GET edit" do

    it "should expose the requested app as @app" do
      pending("Test needs to be brought up to date.")
      App.should_receive(:find).with("37").and_return(mock_app)
      get :edit, :id => "37"
      assigns[:app].should equal(mock_app)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do

      it "should expose a newly created app as @app" do
        pending("Test needs to be brought up to date.")
        App.should_receive(:new).with({'these' => 'params'}).and_return(mock_app(:save => true))
        post :create, :app => {:these => 'params'}
        assigns(:app).should equal(mock_app)
      end

      it "should redirect to the created app" do
        pending("Test needs to be brought up to date.")
        App.stub!(:new).and_return(mock_app(:save => true))
        post :create, :app => {}
        response.should redirect_to(apps_url)
      end

    end

    describe "with invalid params" do

      it "should expose a newly created but unsaved app as @app" do
        pending("Test needs to be brought up to date.")
        App.stub!(:new).with({'these' => 'params'}).and_return(mock_app(:save => false))
        post :create, :app => {:these => 'params'}
        assigns(:app).should equal(mock_app)
      end

      it "should re-render the 'new' template" do
        pending("Test needs to be brought up to date.")
        App.stub!(:new).and_return(mock_app(:save => false))
        post :create, :app => {}
        response.should render_template('new')
      end

    end

  end

  describe "responding to PUT update" do

    describe "with valid params" do

      it "should update the requested app" do
        pending("Test needs to be brought up to date.")
        App.should_receive(:find).with("37").and_return(mock_app)
        mock_app.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :app => {:these => 'params'}
      end

      it "should expose the requested app as @app" do
        App.stub!(:find).and_return(mock_app(:update_attributes => true))
        put :update, :id => "1"
        assigns(:app).should equal(mock_app)
      end

      it "should redirect to the app" do
        App.stub!(:find).and_return(mock_app(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(apps_url)
      end

    end

    describe "with invalid params" do

      it "should update the requested app" do
        pending("Test needs to be brought up to date.")
        App.should_receive(:find).with("37").and_return(mock_app)
        mock_app.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :app => {:these => 'params'}
      end

      it "should expose the app as @app" do
        App.stub!(:find).and_return(mock_app(:update_attributes => false))
        put :update, :id => "1"
        assigns(:app).should equal(mock_app)
      end

      it "should re-render the 'edit' template" do
        App.stub!(:find).and_return(mock_app(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested app" do
      pending("Test needs to be brought up to date.")
      App.should_receive(:find).with(:first, {:conditions=>["id =:link or name =:link", {:link=>mock_app.id}]}).and_return(mock_app)
      mock_app.should_receive(:destroy)
      delete :destroy, :link => mock_app.id, :id => @mock_app.id.to_s
    end

    it "should redirect to the apps list" do
      App.stub!(:find).and_return(mock_app(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(apps_url)
    end

  end


  describe "(examples only using mocks)" do 
    describe "GET index" do 
      describe "as logged in" do 
        before do
          @controller.stub(:logged_in?).and_return(true)
          @user = mock("user", :null_object => true)
          @controller.should_receive(:current_user).any_number_of_times.and_return(@user)
        end
        
        it "should assign all apps the user is administrator of" do 
          @user.should_receive(:administers).and_return(expected_apps = ["app1", "app2"])
          get :index
          assigns[:apps].should == expected_apps
        end
        
        it "should assign user's clients" do 
          @user.should_receive(:clients).and_return(expected_clients = ["client1", "client2"])
          get :index
          assigns[:clients].should == expected_clients
        end
        
        it "should assign subscribable apps" do 
          App.should_receive(:subscribable_by).with(@user).and_return( expected_apps = ["app1", "app2"] )
          get :index
          assigns[:subapps].should == expected_apps
        end
        
        it "should assign all apps" do 
          App.should_receive(:find).with(:all).and_return( expected_apps = ["app1", "app2"] )
          get :index
          assigns[:allapps].should == expected_apps
        end
        
        it "should set flash notice unless user administers any apps" do 
          @user.should_receive(:administers).and_return([])
          get :index
          flash[:notice].should_not be_blank
        end
      end
    end
  end
end
