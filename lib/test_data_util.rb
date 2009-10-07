module TestDataUtil
  def self.load_sample_source_adapters
    ['sources', 'apps', 'users', 'administrations'].each do |fixture|
      Fixtures.create_fixtures(File.join(Rails.root, 'db/migrate'), fixture)  
    end
  end
end