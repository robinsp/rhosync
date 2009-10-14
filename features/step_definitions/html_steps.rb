require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Then /^I should see a link to "([^\"]*)"$/ do |link_text|
  response.should have_tag 'a', link_text
end
