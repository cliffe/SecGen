 require 'spec_helper_acceptance'

describe 'firewall iptmodules' do
  before :all do
    iptables_flush_all_tables
    ip6tables_flush_all_tables
  end

  describe 'iptables ipt_modules tests' do
    context 'all the modules with multiple args' do
      it 'applies' do
        pp = <<-EOS
          class { '::firewall': }
          firewall { '801 - ipt_modules tests':
            proto              => tcp,
            dport              => '8080',
            action             => reject,
            chain              => 'OUTPUT',
            uid                => 0,
            gid                => 404,
            src_range          => "90.0.0.1-90.0.0.2",
            dst_range          => "100.0.0.1-100.0.0.2",
            src_type           => 'LOCAL',
            dst_type           => 'UNICAST',
            physdev_in         => "eth0",
            physdev_out        => "eth1",
            physdev_is_bridged => true,
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => do_catch_changes)
      end

      it 'should contain the rule' do
         shell('iptables-save') do |r|
           expect(r.stdout).to match(/-A OUTPUT -p tcp -m physdev\s+--physdev-in eth0 --physdev-out eth1 --physdev-is-bridged -m iprange --src-range 90.0.0.1-90.0.0.2\s+--dst-range 100.0.0.1-100.0.0.2 -m owner --uid-owner (0|root) --gid-owner 404 -m multiport --dports 8080 -m addrtype --src-type LOCAL --dst-type UNICAST -m comment --comment "801 - ipt_modules tests" -j REJECT --reject-with icmp-port-unreachable/)
         end
      end
    end

    context 'all the modules with single args' do
      it 'applies' do
        pp = <<-EOS
          class { '::firewall': }
          firewall { '802 - ipt_modules tests':
            proto              => tcp,
            dport              => '8080',
            action             => reject,
            chain              => 'OUTPUT',
            gid                => 404,
            dst_range          => "100.0.0.1-100.0.0.2",
            dst_type           => 'UNICAST',
            physdev_out        => "eth1",
            physdev_is_bridged => true,
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => do_catch_changes)
      end

      it 'should contain the rule' do
         shell('iptables-save') do |r|
           expect(r.stdout).to match(/-A OUTPUT -p tcp -m physdev\s+--physdev-out eth1 --physdev-is-bridged -m iprange --dst-range 100.0.0.1-100.0.0.2 -m owner --gid-owner 404 -m multiport --dports 8080 -m addrtype --dst-type UNICAST -m comment --comment "802 - ipt_modules tests" -j REJECT --reject-with icmp-port-unreachable/)
         end
      end
    end
  end

    #iptables version 1.3.5 is not suppored by the ip6tables provider
    if default['platform'] =~ /debian-7/ or default['platform'] =~ /ubuntu-14\.04/
      describe 'ip6tables ipt_modules tests' do
        context 'all the modules with multiple args' do
          it 'applies' do
            pp = <<-EOS
              class { '::firewall': }
              firewall { '801 - ipt_modules tests':
                proto              => tcp,
                dport              => '8080',
                action             => reject,
                chain              => 'OUTPUT',
                provider           => 'ip6tables',
                uid                => 0,
                gid                => 404,
                src_range          => "2001::-2002::",
                dst_range          => "2003::-2004::",
                src_type           => 'LOCAL',
                dst_type           => 'UNICAST',
                physdev_in         => "eth0",
                physdev_out        => "eth1",
                physdev_is_bridged => true,
              }
            EOS

            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => do_catch_changes)
          end

          it 'should contain the rule' do
             shell('ip6tables-save') do |r|
               expect(r.stdout).to match(/-A OUTPUT -p tcp -m physdev\s+--physdev-in eth0 --physdev-out eth1 --physdev-is-bridged -m iprange --src-range 2001::-2002::\s+--dst-range 2003::-2004:: -m owner --uid-owner (0|root) --gid-owner 404 -m multiport --dports 8080 -m addrtype --src-type LOCAL --dst-type UNICAST -m comment --comment "801 - ipt_modules tests" -j REJECT --reject-with icmp6-port-unreachable/)
             end
          end
        end

        context 'all the modules with single args' do
          it 'applies' do
            pp = <<-EOS
              class { '::firewall': }
              firewall { '802 - ipt_modules tests':
                proto              => tcp,
                dport              => '8080',
                action             => reject,
                chain              => 'OUTPUT',
                provider           => 'ip6tables',
                gid                => 404,
                dst_range          => "2003::-2004::",
                dst_type           => 'UNICAST',
                physdev_out        => "eth1",
                physdev_is_bridged => true,
              }
            EOS

            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => do_catch_changes)
          end

          it 'should contain the rule' do
             shell('ip6tables-save') do |r|
               expect(r.stdout).to match(/-A OUTPUT -p tcp -m physdev\s+--physdev-out eth1 --physdev-is-bridged -m iprange --dst-range 2003::-2004:: -m owner --gid-owner 404 -m multiport --dports 8080 -m addrtype --dst-type UNICAST -m comment --comment "802 - ipt_modules tests" -j REJECT --reject-with icmp6-port-unreachable/)
             end
          end
        end
      end
    # Older OSes don't have addrtype so we leave those properties out.
    # el-5 doesn't support ipv6 by default
    elsif default['platform'] !~ /el-5/ and default['platform'] !~ /sles-10/
      describe 'ip6tables ipt_modules tests' do
        context 'all the modules with multiple args' do
          it 'applies' do
            pp = <<-EOS
              class { '::firewall': }
              firewall { '801 - ipt_modules tests':
                proto              => tcp,
                dport              => '8080',
                action             => reject,
                chain              => 'OUTPUT',
                provider           => 'ip6tables',
                uid                => 0,
                gid                => 404,
                src_range          => "2001::-2002::",
                dst_range          => "2003::-2004::",
                physdev_in         => "eth0",
                physdev_out        => "eth1",
                physdev_is_bridged => true,
              }
            EOS

            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => do_catch_changes)
          end

          it 'should contain the rule' do
             shell('ip6tables-save') do |r|
               expect(r.stdout).to match(/-A OUTPUT -p tcp -m physdev\s+--physdev-in eth0 --physdev-out eth1 --physdev-is-bridged -m iprange --src-range 2001::-2002::\s+--dst-range 2003::-2004:: -m owner --uid-owner (0|root) --gid-owner 404 -m multiport --dports 8080 -m comment --comment "801 - ipt_modules tests" -j REJECT --reject-with icmp6-port-unreachable/)
             end
          end
        end

        context 'all the modules with single args' do
          it 'applies' do
            pp = <<-EOS
              class { '::firewall': }
              firewall { '802 - ipt_modules tests':
                proto              => tcp,
                dport              => '8080',
                action             => reject,
                chain              => 'OUTPUT',
                provider           => 'ip6tables',
                gid                => 404,
                dst_range          => "2003::-2004::",
                physdev_out        => "eth1",
                physdev_is_bridged => true,
              }
            EOS

            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => do_catch_changes)
          end

          it 'should contain the rule' do
             shell('ip6tables-save') do |r|
               expect(r.stdout).to match(/-A OUTPUT -p tcp -m physdev\s+--physdev-out eth1 --physdev-is-bridged -m iprange --dst-range 2003::-2004:: -m owner --gid-owner 404 -m multiport --dports 8080 -m comment --comment "802 - ipt_modules tests" -j REJECT --reject-with icmp6-port-unreachable/)
             end
          end
        end
      end
    end

end
