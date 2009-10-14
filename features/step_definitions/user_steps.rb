require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^the user "([^\"]*)" exists$/ do |login|
  Factory(:user, :login => login)
end