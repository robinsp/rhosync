class Factory 
  DEFAULT_PASSWORD = "secret"
end

Factory.define :user do |f|
  f.sequence(:login) {|n| "defaultlogin#{n}" } 
  f.password Factory::DEFAULT_PASSWORD
  f.password_confirmation {|u| u.password }
end
