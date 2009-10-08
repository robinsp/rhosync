# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe User do
  fixtures :users

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end

    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end
  end

  #
  # Validations
  #

  it 'requires login' do
    lambda do
      u = create_user(:login => nil)
      u.errors.on(:login).should_not be_nil
    end.should_not change(User, :count)
  end
  
  describe "adminstrator association to apps" do
    # TODO: I hoping to complete remove the Administation model and replace with 
    # with a has_and_belongs_to_many association. Until we have sufficient tests to 
    # do this safely, this kind of encasulation will have to do.  
    
    # TODO: Remove after habtm is implemented
    def create_administration(app, user)
      Administration.create!(:app => app, :user => user)
    end
    
    describe "administers()" do
      it "should find the applications the user is adminitrator of" do
        guitar_store = Factory.create(:app, :name => "GuitarStore")
        piano_store = Factory.create(:app, :name => "PianoStore")
        
        musician = Factory.create(:user)
        create_administration(guitar_store, musician)
        create_administration(piano_store, musician)
        
        guitarist = Factory.create(:user)
        create_administration(guitar_store, guitarist)
        
        truck_driver = Factory.create(:user)
        
        truck_driver.administers.should be_empty
        
        guitarist.administers.should include(guitar_store)
        guitarist.administers.should_not include(piano_store)
        
        musician.administers.should include(piano_store, guitar_store)
      end
    end
    
    describe "membership_of(App)" do
      before do 
        @app_one = Factory(:app)
        @app_two = Factory(:app)
        @app_of_which_user_is_not_a_member = Factory(:app)
        
        @user = Factory(:user)
        @user.apps << @app_one
        @user.apps << @app_two
      end
      
      it "should return the Memebership when user is a subscriber of app" do 
        [@app_one, @app_two].each do |app|
          @user.membership_of(app).should_not be_nil
          @user.membership_of(app).should be_a(Membership)
          @user.membership_of(app).user.should == @user
          @user.membership_of(app).app.should == app
        end
      end
      
      it "should return nil if user is not a subscriber to the app" do 
        @user.membership_of(@app_of_which_user_is_not_a_member).should be_nil
      end
      
    end
    
    describe "administers?(App)" do
      before do 
        @guitar_store = Factory.create(:app, :name => "GuitarStore")
        @piano_store = Factory.create(:app, :name => "PianoStore")
        
        @musician = Factory.create(:user)
        create_administration(@guitar_store, @musician)
        create_administration(@piano_store, @musician)
        
        @guitarist = Factory.create(:user)
        create_administration(@guitar_store, @guitarist)
        
        @truck_driver = Factory.create(:user)
      end
      
      it "should check if user is the administrator of an specific app" do 
        @truck_driver.administers?(@piano_store).should be_false
        @truck_driver.administers?(@guitar_store).should be_false
        
        @guitarist.administers?(@piano_store).should be_false
        @guitarist.administers?(@guitar_store).should be_true
        
        @musician.administers?(@piano_store).should be_true
        @musician.administers?(@guitar_store).should be_true
      end
      
      it "should return false if passed an unsaved app" do 
        @musician.administers?(App.new(:name => "AnApp")).should be_false
      end
      
      it "should return false if passed a 'nil' app" do 
        @musician.administers?(nil).should be_false
      end
    end
  end

  describe 'allows legitimate logins:' do
    ['123', '1234567890_234567890_234567890_234567890',
     'hello.-_there@funnychar.com'].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_user(:login => login_str)
          u.errors.on(:login).should     be_nil
        end.should change(User, :count).by(1)
      end
    end
  end
  describe 'disallows illegitimate logins:' do
    ['12', '1234567890_234567890_234567890_234567890_', "tab\t", "newline\n",
     "Iñtërnâtiônàlizætiøn hasn't happened to ruby 1.8 yet",
     'semicolon;', 'quote"', 'tick\'', 'backtick`', 'percent%', 'plus+', 'space '].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_user(:login => login_str)
          u.errors.on(:login).should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end

  it 'requires password' do
    lambda do
      u = create_user(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_user(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(User, :count)
  end
  
  describe 'allows legitimate names:' do
    ['Andre The Giant (7\'4", 520 lb.) -- has a posse',
     '', '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890',
    ].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          u = create_user(:name => name_str)
          u.errors.on(:name).should     be_nil
        end.should change(User, :count).by(1)
      end
    end
  end
  describe "disallows illegitimate names" do
    ["tab\t", "newline\n",
     '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_',
     ].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          u = create_user(:name => name_str)
          u.errors.on(:name).should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end

  it 'resets password' do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('quentin', 'new password').should == users(:quentin)
  end

  it 'does not rehash password' do
    users(:quentin).update_attributes(:login => 'quentin2')
    User.authenticate('quentin2', 'monkey').should == users(:quentin)
  end

  #
  # Authentication
  #

  it 'authenticates user' do
    User.authenticate('quentin', 'monkey').should == users(:quentin)
  end

  it "doesn't authenticate user with bad password" do
    User.authenticate('quentin', 'invalid_password').should be_nil
  end

 if REST_AUTH_SITE_KEY.blank?
   # old-school passwords
   it "authenticates a user against a hard-coded old-style password" do
     User.authenticate('old_password_holder', 'test').should == users(:old_password_holder)
   end
 else
   it "doesn't authenticate a user against a hard-coded old-style password" do
     User.authenticate('old_password_holder', 'test').should be_nil
   end

   # New installs should bump this up and set REST_AUTH_DIGEST_STRETCHES to give a 10ms encrypt time or so
   desired_encryption_expensiveness_ms = 0.1
   it "takes longer than #{desired_encryption_expensiveness_ms}ms to encrypt a password" do
     test_reps = 100
     start_time = Time.now; test_reps.times{ User.authenticate('quentin', 'monkey'+rand.to_s) }; end_time   = Time.now
     auth_time_ms = 1000 * (end_time - start_time)/test_reps
     auth_time_ms.should > desired_encryption_expensiveness_ms
   end
 end

  #
  # Authentication
  #

  it 'sets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).forget_me
    users(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

protected
  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.save
    record
  end
end
