require 'active_record/fixtures'

namespace :db do
  desc "bootstrap database with sample source adapters"
  task :bootstrap => 'db:fixtures:samples' do
  end
  
  namespace :fixtures do
    desc "load sample source adapters"
    task :samples => ['db:create','db:schema:load'] do
      TestDataUtil.load_sample_source_adapters
    end
  end
end