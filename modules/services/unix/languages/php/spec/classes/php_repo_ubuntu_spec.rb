require 'spec_helper'

describe 'php::repo::ubuntu', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      case facts[:lsbdistcodename]
      when 'trusty'
        describe 'when called with no parameters on Ubuntu trusty' do
          it {
            should contain_exec('add-apt-repository-ppa:ondrej/php')
          }
        end

        describe 'when called with version 7.0 on Ubuntu trusty' do
          let(:params) {{
              :version => '7.0'
          }}
          it {
            should contain_exec('add-apt-repository-ppa:ondrej/php')
          }
        end

        describe 'when call with version 5.6 on Ubuntu trusty' do
          let(:params) {{
              :version => '5.6'
          }}
          it {
            should contain_exec('add-apt-repository-ppa:ondrej/php')
          }
        end

        describe 'when call with version 5.4 on Ubuntu trusty' do
          let(:params) {{
              :version => '5.4',
          }}
          it { expect { should raise_error(Puppet::Error) }}
        end

      end
    end
  end
end
