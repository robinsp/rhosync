require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

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