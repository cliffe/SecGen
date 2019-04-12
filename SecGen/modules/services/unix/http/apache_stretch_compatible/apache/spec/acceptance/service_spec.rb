require 'spec_helper_acceptance'

describe 'apache::service class' do
  describe 'adding dependencies in between the base class and service class' do
    let(:pp) do
      <<-EOS
        class { 'apache': }
        file { '/tmp/test':
          require => Class['apache'],
          notify  => Class['apache::service'],
        }
      EOS
    end

    # Run it twice and test for idempotency
    it_behaves_like "a idempotent resource"
  end
end
