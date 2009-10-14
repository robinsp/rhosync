require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^a clean database$/ do
  models = Module.constants.select do |constant_name|
    constant = eval constant_name
    if not constant.nil? and constant.is_a? Class and constant.superclass == ActiveRecord::Base
      constant
    end
  end
  
  # TODO: Figure out why there's no device in my database /Robin
  models.each do |model|
    eval "#{model}.all.each {|i| i.destroy }" unless model == "Device"
  end
end

Given /^sample source adapters loaded from fixtures$/ do
  TestDataUtil.load_sample_source_adapters
end

Then /^database has no "([^\"]*)"$/ do |model|
  eval("#{model.singularize}.all").should be_empty
end