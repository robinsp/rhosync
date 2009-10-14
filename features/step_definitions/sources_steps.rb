require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Then /^I should see a non\-empty table of "([^\"]*)" objects$/ do |source_name|
  response.should have_tag 'h1', source_name
  response.should have_tag 'table#objects' do 
    with_tag "tr", :minimum => 1
  end
end