require 'spec_helper_acceptance'

# Some tests for the standard recommended usage
describe 'standard usage tests' do
  it 'applies twice' do
    pp = <<-EOS
      class my_fw::pre {
        Firewall {
          require => undef,
        }

        # Default firewall rules
        firewall { '000 accept all icmp':
          proto   => 'icmp',
          action  => 'accept',
        }->
        firewall { '001 accept all to lo interface':
          proto   => 'all',
          iniface => 'lo',
          action  => 'accept',
        }->
        firewall { "0002 reject local traffic not on loopback interface":
          iniface     => '! lo',
          destination => '127.0.0.1/8',
          action      => 'reject',
        }->
        firewall { '003 accept related established rules':
          proto   => 'all',
          ctstate => ['RELATED', 'ESTABLISHED'],
          action  => 'accept',
        }
      }
      class my_fw::post {
        firewall { '999 drop all':
          proto   => 'all',
          action  => 'drop',
          before  => undef,
        }
      }
      resources { "firewall":
        purge => true
      }
      Firewall {
        before  => Class['my_fw::post'],
        require => Class['my_fw::pre'],
      }
      class { ['my_fw::pre', 'my_fw::post']: }
      class { 'firewall': }
      firewall { '500 open up port 22':
        action => 'accept',
        proto => 'tcp',
        dport => 22,
      }
    EOS

    # Run it twice and test for idempotency
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => do_catch_changes)
  end
end
