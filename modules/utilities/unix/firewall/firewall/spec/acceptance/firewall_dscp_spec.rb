require 'spec_helper_acceptance'

describe 'firewall DSCP' do
  before :all do
    iptables_flush_all_tables
    ip6tables_flush_all_tables
  end

  describe 'dscp ipv4 tests' do
    context 'set_dscp 0x01' do
      it 'applies' do
        pp = <<-EOS
          class { '::firewall': }
          firewall {
            '1000 - set_dscp':
              proto     => 'tcp',
              jump      => 'DSCP',
              set_dscp  => '0x01',
              port      => '997',
              chain     => 'OUTPUT',
              table     => 'mangle',
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      it 'should contain the rule' do
        shell('iptables-save -t mangle') do |r|
          expect(r.stdout).to match(/-A OUTPUT -p tcp -m multiport --ports 997 -m comment --comment "1000 - set_dscp" -j DSCP --set-dscp 0x01/)
        end
      end
    end

    context 'set_dscp_class EF' do
      it 'applies' do
        pp = <<-EOS
          class { '::firewall': }
          firewall {
            '1001 EF - set_dscp_class':
              proto          => 'tcp',
              jump           => 'DSCP',
              port           => '997',
              set_dscp_class => 'EF',
              chain          => 'OUTPUT',
              table          => 'mangle',
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      it 'should contain the rule' do
        shell('iptables-save') do |r|
          expect(r.stdout).to match(/-A OUTPUT -p tcp -m multiport --ports 997 -m comment --comment "1001 EF - set_dscp_class" -j DSCP --set-dscp 0x2e/)
        end
      end
    end
  end

  if default['platform'] !~ /el-5/ and default['platform'] !~ /sles-10/
    describe 'dscp ipv6 tests' do
      context 'set_dscp 0x01' do
        it 'applies' do
          pp = <<-EOS
            class { '::firewall': }
            firewall {
              '1002 - set_dscp':
                proto     => 'tcp',
                jump      => 'DSCP',
                set_dscp  => '0x01',
                port      => '997',
                chain     => 'OUTPUT',
                table     => 'mangle',
                provider  => 'ip6tables',
            }
          EOS

          apply_manifest(pp, :catch_failures => true)
        end

        it 'should contain the rule' do
          shell('ip6tables-save -t mangle') do |r|
            expect(r.stdout).to match(/-A OUTPUT -p tcp -m multiport --ports 997 -m comment --comment "1002 - set_dscp" -j DSCP --set-dscp 0x01/)
          end
        end
      end

      context 'set_dscp_class EF' do
        it 'applies' do
          pp = <<-EOS
            class { '::firewall': }
            firewall {
              '1003 EF - set_dscp_class':
                proto          => 'tcp',
                jump           => 'DSCP',
                port           => '997',
                set_dscp_class => 'EF',
                chain          => 'OUTPUT',
                table          => 'mangle',
                provider       => 'ip6tables',
            }
          EOS

          apply_manifest(pp, :catch_failures => true)
        end

        it 'should contain the rule' do
          shell('ip6tables-save') do |r|
            expect(r.stdout).to match(/-A OUTPUT -p tcp -m multiport --ports 997 -m comment --comment "1003 EF - set_dscp_class" -j DSCP --set-dscp 0x2e/)
          end
        end
      end
    end
  end

end
