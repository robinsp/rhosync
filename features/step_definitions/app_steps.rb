require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Then /^I should not see an application list$/ do
  response.should_not have_tag "table.cukeApps" 
end

Then /^I should see the following applications:$/ do |table|
  puts table.raw.inspect
  table.raw.each do |row|
    response.should have_tag "table.cukeApps tr" do 
      with_tag "td", row.first
    end
  end
end
