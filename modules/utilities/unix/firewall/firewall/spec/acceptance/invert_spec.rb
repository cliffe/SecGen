require 'spec_helper_acceptance'

describe 'firewall inverting' do
  before :all do
    iptables_flush_all_tables
    ip6tables_flush_all_tables
  end

  context "inverting rules" do
    it 'applies' do
      pp = <<-EOS
        class { '::firewall': }
        firewall { '601 disallow esp protocol':
          action => 'accept',
          proto  => '! esp',
        }
        firewall { '602 drop NEW external website packets with FIN/RST/ACK set and SYN unset':
          chain     => 'INPUT',
          state     => 'NEW',
          action    => 'drop',
          proto     => 'tcp',
          sport     => ['! http', '! 443'],
          source    => '! 10.0.0.0/8',
          tcp_flags => '! FIN,SYN,RST,ACK SYN',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => do_catch_changes)
    end

    it 'should contain the rules' do
      shell('iptables-save') do |r|
        if (fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') == '5') or (default['platform'] =~ /sles-10/)
          expect(r.stdout).to match(/-A INPUT -p ! esp -m comment --comment "601 disallow esp protocol" -j ACCEPT/)
          expect(r.stdout).to match(/-A INPUT -s ! 10\.0\.0\.0\/255\.0\.0\.0 -p tcp -m tcp ! --tcp-flags FIN,SYN,RST,ACK SYN -m multiport --sports ! 80,443 -m comment --comment "602 drop NEW external website packets with FIN\/RST\/ACK set and SYN unset" -m state --state NEW -j DROP/)
        else
          expect(r.stdout).to match(/-A INPUT ! -p esp -m comment --comment "601 disallow esp protocol" -j ACCEPT/)
          expect(r.stdout).to match(/-A INPUT ! -s 10\.0\.0\.0\/8 -p tcp -m tcp ! --tcp-flags FIN,SYN,RST,ACK SYN -m multiport ! --sports 80,443 -m comment --comment "602 drop NEW external website packets with FIN\/RST\/ACK set and SYN unset" -m state --state NEW -j DROP/)
        end
      end
    end
  end
  context "inverting partial array rules" do
    it 'raises a failure' do
      pp = <<-EOS
        class { '::firewall': }
        firewall { '603 drop 80,443 traffic':
          chain     => 'INPUT',
          action    => 'drop',
          proto     => 'tcp',
          sport     => ['! http', '443'],
        }
      EOS

      apply_manifest(pp, :expect_failures => true) do |r|
        expect(r.stderr).to match(/is not prefixed/)
      end
    end
  end
end
