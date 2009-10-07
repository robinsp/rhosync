module TestDataUtil
  def self.load_sample_source_adapters
    Fixtures.create_fixtures(File.join(File.dirname(__FILE__), '..', 'db', 'migrate'), 'sources')      
    Fixtures.create_fixtures(File.join(File.dirname(__FILE__), '..', 'db', 'migrate'), 'apps')
    Fixtures.create_fixtures(File.join(File.dirname(__FILE__), '..', 'db', 'migrate'), 'users')      
    Fixtures.create_fixtures(File.join(File.dirname(__FILE__), '..', 'db', 'migrate'), 'administrations')
  end
end