 require 'spec_helper_acceptance'

describe 'firewall bridging' do
  before :all do
    iptables_flush_all_tables
    ip6tables_flush_all_tables
  end

  describe 'iptables physdev tests' do
    context 'physdev_in eth0' do
        it 'applies' do
          pp = <<-EOS
            class { '::firewall': }
            firewall { '701 - test':
              chain => 'FORWARD',
              proto  => tcp,
              port   => '701',
              action => accept,
              physdev_in => 'eth0',
            }
          EOS

          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes => do_catch_changes)
        end

        it 'should contain the rule' do
           shell('iptables-save') do |r|
             expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 -m multiport --ports 701 -m comment --comment "701 - test" -j ACCEPT/)
           end
        end
      end

      context 'physdev_out eth1' do
        it 'applies' do
          pp = <<-EOS
            class { '::firewall': }
            firewall { '702 - test':
              chain => 'FORWARD',
              proto  => tcp,
              port   => '702',
              action => accept,
              physdev_out => 'eth1',
            }
          EOS

          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes => do_catch_changes)
        end

        it 'should contain the rule' do
           shell('iptables-save') do |r|
             expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-out eth1 -m multiport --ports 702 -m comment --comment "702 - test" -j ACCEPT/)
           end
        end
      end

      context 'physdev_in eth0 and physdev_out eth1' do
        it 'applies' do
          pp = <<-EOS
            class { '::firewall': }
            firewall { '703 - test':
              chain => 'FORWARD',
              proto  => tcp,
              port   => '703',
              action => accept,
              physdev_in => 'eth0',
              physdev_out => 'eth1',
            }
          EOS

          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes => do_catch_changes)
        end

        it 'should contain the rule' do
           shell('iptables-save') do |r|
             expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 --physdev-out eth1 -m multiport --ports 703 -m comment --comment "703 - test" -j ACCEPT/)
           end
        end
      end

      context 'physdev_is_bridged' do
        it 'applies' do
          pp = <<-EOS
            class { '::firewall': }
            firewall { '704 - test':
              chain => 'FORWARD',
              proto  => tcp,
              port   => '704',
              action => accept,
              physdev_is_bridged => true,
            }
          EOS

          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes => do_catch_changes)
        end

        it 'should contain the rule' do
           shell('iptables-save') do |r|
             expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-is-bridged -m multiport --ports 704 -m comment --comment "704 - test" -j ACCEPT/)
           end
        end
      end

      context 'physdev_in eth0 and physdev_is_bridged' do
        it 'applies' do
          pp = <<-EOS
            class { '::firewall': }
            firewall { '705 - test':
              chain => 'FORWARD',
              proto  => tcp,
              port   => '705',
              action => accept,
              physdev_in => 'eth0',
              physdev_is_bridged => true,
            }
          EOS

          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes => do_catch_changes)
        end

        it 'should contain the rule' do
           shell('iptables-save') do |r|
             expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 --physdev-is-bridged -m multiport --ports 705 -m comment --comment "705 - test" -j ACCEPT/)
           end
        end
      end

      context 'physdev_out eth1 and physdev_is_bridged' do
        it 'applies' do
          pp = <<-EOS
            class { '::firewall': }
            firewall { '706 - test':
              chain => 'FORWARD',
              proto  => tcp,
              port   => '706',
              action => accept,
              physdev_out => 'eth1',
              physdev_is_bridged => true,
            }
          EOS

          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes => do_catch_changes)
        end

        it 'should contain the rule' do
           shell('iptables-save') do |r|
             expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-out eth1 --physdev-is-bridged -m multiport --ports 706 -m comment --comment "706 - test" -j ACCEPT/)
           end
        end
      end

      context 'physdev_in eth0 and physdev_out eth1 and physdev_is_bridged' do
        it 'applies' do
          pp = <<-EOS
            class { '::firewall': }
            firewall { '707 - test':
              chain => 'FORWARD',
              proto  => tcp,
              port   => '707',
              action => accept,
              physdev_in => 'eth0',
              physdev_out => 'eth1',
              physdev_is_bridged => true,
            }
          EOS

          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes => do_catch_changes)
        end

        it 'should contain the rule' do
           shell('iptables-save') do |r|
             expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 --physdev-out eth1 --physdev-is-bridged -m multiport --ports 707 -m comment --comment "707 - test" -j ACCEPT/)
           end
        end
      end

    end

    #iptables version 1.3.5 is not suppored by the ip6tables provider
    if default['platform'] !~ /el-5/ and default['platform'] !~ /sles-10/
      describe 'ip6tables physdev tests' do
        context 'physdev_in eth0' do
          it 'applies' do
            pp = <<-EOS
              class { '::firewall': }
              firewall { '701 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '701',
                action => accept,
                physdev_in => 'eth0',
              }
            EOS

            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => do_catch_changes)
          end

          it 'should contain the rule' do
             shell('ip6tables-save') do |r|
               expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 -m multiport --ports 701 -m comment --comment "701 - test" -j ACCEPT/)
             end
          end
        end

        context 'physdev_out eth1' do
          it 'applies' do
            pp = <<-EOS
              class { '::firewall': }
              firewall { '702 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '702',
                action => accept,
                physdev_out => 'eth1',
              }
            EOS

            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => do_catch_changes)
          end

          it 'should contain the rule' do
             shell('ip6tables-save') do |r|
               expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-out eth1 -m multiport --ports 702 -m comment --comment "702 - test" -j ACCEPT/)
             end
          end
        end

        context 'physdev_in eth0 and physdev_out eth1' do
          it 'applies' do
            pp = <<-EOS
              class { '::firewall': }
              firewall { '703 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '703',
                action => accept,
                physdev_in => 'eth0',
                physdev_out => 'eth1',
              }
            EOS

            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => do_catch_changes)
          end

          it 'should contain the rule' do
             shell('ip6tables-save') do |r|
               expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 --physdev-out eth1 -m multiport --ports 703 -m comment --comment "703 - test" -j ACCEPT/)
             end
          end
        end

        context 'physdev_is_bridged' do
          it 'applies' do
            pp = <<-EOS
              class { '::firewall': }
              firewall { '704 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '704',
                action => accept,
                physdev_is_bridged => true,
              }
            EOS

            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => do_catch_changes)
          end

          it 'should contain the rule' do
             shell('ip6tables-save') do |r|
               expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-is-bridged -m multiport --ports 704 -m comment --comment "704 - test" -j ACCEPT/)
             end
          end
        end

        context 'physdev_in eth0 and physdev_is_bridged' do
          it 'applies' do
            pp = <<-EOS
              class { '::firewall': }
              firewall { '705 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '705',
                action => accept,
                physdev_in => 'eth0',
                physdev_is_bridged => true,
              }
            EOS

            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => do_catch_changes)
          end

          it 'should contain the rule' do
             shell('ip6tables-save') do |r|
               expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 --physdev-is-bridged -m multiport --ports 705 -m comment --comment "705 - test" -j ACCEPT/)
             end
          end
        end

        context 'physdev_out eth1 and physdev_is_bridged' do
          it 'applies' do
            pp = <<-EOS
              class { '::firewall': }
              firewall { '706 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '706',
                action => accept,
                physdev_out => 'eth1',
                physdev_is_bridged => true,
              }
            EOS

            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => do_catch_changes)
          end

          it 'should contain the rule' do
             shell('ip6tables-save') do |r|
               expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-out eth1 --physdev-is-bridged -m multiport --ports 706 -m comment --comment "706 - test" -j ACCEPT/)
             end
          end
        end

        context 'physdev_in eth0 and physdev_out eth1 and physdev_is_bridged' do
          it 'applies' do
            pp = <<-EOS
              class { '::firewall': }
              firewall { '707 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '707',
                action => accept,
                physdev_in => 'eth0',
                physdev_out => 'eth1',
                physdev_is_bridged => true,
              }
            EOS

            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => do_catch_changes)
          end

          it 'should contain the rule' do
             shell('ip6tables-save') do |r|
               expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 --physdev-out eth1 --physdev-is-bridged -m multiport --ports 707 -m comment --comment "707 - test" -j ACCEPT/)
             end
          end
        end
      end
    end
end
