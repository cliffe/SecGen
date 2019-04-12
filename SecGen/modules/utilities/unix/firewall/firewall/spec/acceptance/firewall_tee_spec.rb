require 'spec_helper_acceptance'

describe 'firewall tee' do
  before :all do
    iptables_flush_all_tables
    ip6tables_flush_all_tables
  end

  if default['platform'] =~ /ubuntu-1404/ or default['platform'] =~ /ubuntu-1204/ or default['platform'] =~ /debian-7/ or default['platform'] =~ /debian-8/ or default['platform'] =~ /el-7/
    describe 'tee_gateway' do
      context '10.0.0.2' do
        it 'applies' do
          pp = <<-EOS
            class { '::firewall': }
            firewall {
              '810 - tee_gateway':
                chain   => 'PREROUTING',
                table   => 'mangle',
                jump    => 'TEE',
                gateway => '10.0.0.2',
                proto   => all,
            }
          EOS

          apply_manifest(pp, :catch_failures => true)
        end

        it 'should contain the rule' do
          shell('iptables-save -t mangle') do |r|
            expect(r.stdout).to match(/-A PREROUTING -m comment --comment "810 - tee_gateway" -j TEE --gateway 10.0.0.2/)
          end
        end
      end
    end

    describe 'tee_gateway6' do
      context '2001:db8::1' do
        it 'applies' do
          pp = <<-EOS
            class { '::firewall': }
            firewall {
              '811 - tee_gateway6':
                chain    => 'PREROUTING',
                table    => 'mangle',
                jump     => 'TEE',
                gateway  => '2001:db8::1',
                proto   => all,
                provider => 'ip6tables',
            }
          EOS

          apply_manifest(pp, :catch_failures => true)
        end

        it 'should contain the rule' do
          shell('ip6tables-save -t mangle') do |r|
            expect(r.stdout).to match(/-A PREROUTING -m comment --comment "811 - tee_gateway6" -j TEE --gateway 2001:db8::1/)
          end
        end
      end
    end
  end

end
