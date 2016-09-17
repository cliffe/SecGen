RSpec.configure do |config|
  config.mock_with :rspec
end

def with_debian_facts
  let :facts do
    {
      :kernel          => 'Linux',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '8.0',
      :osfamily        => 'Debian',
    }
  end
end
