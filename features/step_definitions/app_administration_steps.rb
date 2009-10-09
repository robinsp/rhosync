require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^the user "([^\"]*)" exists$/ do |login|
  Factory(:user, :login => login)
end

Given /^I'm logged in as "([^\"]*)"$/ do |login|
  Given "the user \"#{login}\" exists"
  When "I login to web app as \"#{login}\""
end

When /^I login to web app as "([^\"]*)"$/ do |login|
  When "I go to the login page"
  When "I fill in \"Login\" with \"#{login}\""
  When "I fill in \"Password\" with \"#{Factory::DEFAULT_PASSWORD}\""
  When "I press \"Log in\""
end

Then /^I should not see an application list$/ do
  response.should_not have_tag "table.cukeApps" 
end

Then /^I should see the following applications:$/ do |table|
  table.raw.each do |row|
    response.should have_tag "table.cukeApps tr" do 
      with_tag "td", row.first
    end
  end
end
