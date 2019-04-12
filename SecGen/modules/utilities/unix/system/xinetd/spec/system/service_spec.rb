require 'spec_helper_system'

describe 'adding a service' do
  describe puppet_apply(<<-EOS
      class { 'xinetd': }
      xinetd::service { 'tftp':
        port        => '69',
        server      => '/usr/sbin/in.tftpd',
        server_args => '-s $base',
        socket_type => 'dgram',
        protocol    => 'udp',
        cps         => '100 2',
        flags       => 'IPv4',
        per_source  => '11',
      }
    EOS
  ) do
    its(:exit_code) { should_not eq(1) }
    its(:refresh) { should be_nil }
    its(:exit_code) { should be_zero }
  end

  describe service('xinetd') do
    it { should be_running }
    it { should be_enabled }
  end
end
