require File.dirname(__FILE__) + "/../../../spec_helper"
require File.dirname(__FILE__) + "/sync_spec_helper"
require 'sync'

describe "Sync.Synchronizer" do
  before do 
    @sync_data = {}
    @source_id = 123
    @object_limit = 456
    @user_id = 789
    ObjectValue.all.should be_empty
  end
  
  describe "sync" do 
    it "should work with String id:s" do 
      sync triple(expected_object = "a-string", "name", "value")
      ObjectValue.first.object.should == expected_object
    end
    
    it "should ignore object_values named 'id'" do
      sync triple("123", "id", "ignore me")
      ObjectValue.all.should be_empty
    end
    
    it "should ignore object_values named 'attrib_type'" do
      sync triple("123", "attrib_type", "ignore me")
      ObjectValue.all.should be_empty
    end
    
    it "should ignore the complete object if it contains invalid attributes" do
      sync triples( 
        triple("51", "attrib", "valid"),
        triple("51", "attrib_type", "invalid"),
        triple("51", "id", "invalid")
      )
      ObjectValue.all.should be_empty
    end
    
    it "should not ignore valid object when invalid objects are present" do 
      sync triples( 
        triple("51", "attrib_type", "invalid", "id", "invalid"),
        triple("52", "attrib", "valid!")
      )
      ObjectValue.all.size.should == 1
    end
    
    it "should use default source_id from @source" do
      expected_source_id = 321
      sync triple("123", "attrib-name", "value"), :source_id => expected_source_id
      ObjectValue.first.source_id.should == expected_source_id
    end
    
    it "should convert Fixnum values into strings"
    
    it "should create an object_value" do
      data = triple("1234", "attrib", "value")
      Sync::Synchronizer.new(data, @source_id).sync
      ObjectValue.all.size.should == 1
    end
    
    it "should ignore object_value where attribute name is blank" do 
      sync triple("123", "", "ignore me")
      ObjectValue.all.should be_empty
      
      sync triple("123", nil, "ignore me")
      ObjectValue.all.should be_empty
    end
    
    it "should ignore object_value where attribute value is blank" do 
      sync triple("123", "attrib-name", "")
      ObjectValue.all.should be_empty
      
      sync triple("123", "attrib-name", nil)
      ObjectValue.all.should be_empty
    end
    
    it "should not insert more items than the configured limit" do
      sync triples( 
        triple("51", "attrib", "value"),
        triple("52", "attrib", "value"),
        triple("53", "attrib", "value"),
        triple("54", "attrib", "value")
      ), :limit => (expected_object_count = 3)
                                      
      ObjectValue.all.size.should == expected_object_count
    end
    
    it "should save ObjectValue.value" do
      sync triple("object-id", "attrib-name", expected_value = "attrib-value")
      ObjectValue.first.value.should == expected_value
    end
    
    it "should save ObjectValue.attrib" do
      sync triple("object-id", expected_attrib = "attrib-name", "attrib-value")
      ObjectValue.first.attrib.should == expected_attrib
    end
    
    it "should store given id as ObjectValue.object" do 
      sync triple(expected_object = "55", "attrib", "value")
      ObjectValue.first.object.should == expected_object
    end
    
    it "should save the user id" do
      sync triple("object-id", "attrib-name", "attrib-value"), :user_id => (expected_user_id = 1234)
      ObjectValue.first.user_id.should == expected_user_id
    end
    
    it "should create one object_value per attribute" do 
      data = triples(triple("123", "name1", "value1"),
                      triple("789", "name3", "value3", "name4", "value4") )
      Sync::Synchronizer.new(data, @source_id).sync
      ObjectValue.all.size.should == 3
    end
    
    it "should handle single quotes in attribute values" do
      sync triple("not-used", "not-used", attribute_value = "'")
      ObjectValue.first.value.should == attribute_value
    end
    
    it "should override default source_id when given as object_value" do 
      pending "This spec will not work. I doubt this part of the SourceAdapter implementation has ever been run"
      sync triple("123", "attrib-name", "value", :source_id, expected_source_id = 1234)
      ObjectValue.first.source_id.should == expected_source_id
    end
    
  end
  
  
  
  
  describe "initialize" do 
    it "should raise error when sync_data param is nil" do 
      lambda { Sync::Synchronizer.new(nil, @source_id) }.should raise_error(Sync::IllegalArgumentError)
    end
    
    it "should raise error when sync_data param is not a hash" do 
      mock = mock("non-hash")
      mock.should_receive(:is_a?).with(Hash).and_return(false)
      lambda { Sync::Synchronizer.new(mock, @source_id) }.should raise_error(Sync::IllegalArgumentError)
    end
    
    it "should allow sync_data param hash to be empty" do 
      lambda { Sync::Synchronizer.new({}, @source_id) }.should_not raise_error
    end
    
    it "should raise error when source_id param is nil" do 
      lambda { Sync::Synchronizer.new(@sync_data, nil) }.should raise_error(Sync::IllegalArgumentError)
    end
    
    it "should raise error if source_id is less than 1" do 
      lambda { Sync::Synchronizer.new(@sync_data, 0) }.should raise_error(Sync::IllegalArgumentError)
    end
    
    it "should raise error if source_id param is not Fixnum" do
      mock = mock("non-fixnum", :null_object => true)
      mock.should_receive(:is_a?).with(Fixnum).and_return(false)
      lambda { Sync::Synchronizer.new(@sync_data, mock) }.should raise_error(Sync::IllegalArgumentError)
    end 
    
    it "should not require limit and user_id params" do 
      lambda { Sync::Synchronizer.new(@sync_data, @source_id) }.should_not raise_error
    end
    
    
    it "should raise error if object_limit param is not Fixnum" do
      mock = mock("non-fixnum", :null_object => true)
      mock.should_receive(:is_a?).with(Fixnum).and_return(false)
      lambda { Sync::Synchronizer.new(@sync_data, @source_id, mock) }.should raise_error(Sync::IllegalArgumentError)
    end
    
    it "should raise error if object_limit is less than 1" do 
      lambda { Sync::Synchronizer.new(@sync_data, @source_id, 0) }.should raise_error(Sync::IllegalArgumentError)
    end
    
    it "should allow object_limit to be nil" do 
      lambda { Sync::Synchronizer.new(@sync_data, @source_id, nil) }.should_not raise_error
    end
    
    it "should raise error if user_id param is not Fixnum" do 
      mock = mock("non-fixnum", :null_object => true)
      mock.should_receive(:is_a?).with(Fixnum).and_return(false)
      lambda { Sync::Synchronizer.new(@sync_data, @source_id, @object_limit, mock) }.should raise_error(Sync::IllegalArgumentError)
    end
    
    it "should raise error if user_id less than 1" do 
      lambda { Sync::Synchronizer.new(@sync_data, @source_id, @object_limit, 0) }.should raise_error(Sync::IllegalArgumentError)
    end
    
    it "should allow user_id to be nil" do 
      lambda { Sync::Synchronizer.new(@sync_data, @source_id, nil, nil) }.should_not raise_error
    end
    
    it "should save params as attributes" do 
      obj = Sync::Synchronizer.new(@sync_data, @source_id, @object_limit, @user_id)
      obj.sync_data.should == @sync_data
      obj.object_limit.should == @object_limit
      obj.user_id.should == @user_id
      obj.source_id.should == @source_id
    end
  end
  
  it "should work with Fixnum id:s" do 
    pending "Feature request. Robin Spainhour"
  end
  
  # Local helper
  def sync(data, options = {})
    source_id = options[:source_id] ||= @source_id
    limit = options[:limit] ||= nil
    user_id = options[:user_id] ||= nil
    Sync::Synchronizer.new(data, source_id, limit, user_id).sync
  end

end