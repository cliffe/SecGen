require 'spec_helper_acceptance'

describe 'param based tests' do
  before :all do
    iptables_flush_all_tables
    ip6tables_flush_all_tables
  end

  it 'test various params', :unless => (default['platform'].match(/el-5/) || fact('operatingsystem') == 'SLES') do
    iptables_flush_all_tables

    ppm = <<-EOS
    firewall { '100 test':
      table     => 'raw',
      socket    => 'true',
      chain     => 'PREROUTING',
      jump      => 'LOG',
      log_level => 'debug',
    }
    EOS

    expect(apply_manifest(ppm, :catch_failures => true).exit_code).to eq(2)
    expect(apply_manifest(ppm, :catch_failures => true).exit_code).to be_zero
  end

  it 'test log rule' do
    iptables_flush_all_tables

    ppm = <<-EOS
    firewall { '998 log all':
      proto     => 'all',
      jump      => 'LOG',
      log_level => 'debug',
    }
    EOS
    expect(apply_manifest(ppm, :catch_failures => true).exit_code).to eq(2)
    expect(apply_manifest(ppm, :catch_failures => true).exit_code).to be_zero
  end

  it 'test log rule - changing names' do
    iptables_flush_all_tables

    ppm1 = <<-EOS
    firewall { '004 log all INVALID packets':
      chain      => 'INPUT',
      proto      => 'all',
      ctstate    => 'INVALID',
      jump       => 'LOG',
      log_level  => '3',
      log_prefix => 'IPTABLES dropped invalid: ',
    }
    EOS

    ppm2 = <<-EOS
    firewall { '003 log all INVALID packets':
      chain      => 'INPUT',
      proto      => 'all',
      ctstate    => 'INVALID',
      jump       => 'LOG',
      log_level  => '3',
      log_prefix => 'IPTABLES dropped invalid: ',
    }
    EOS

    expect(apply_manifest(ppm1, :catch_failures => true).exit_code).to eq(2)

    ppm = <<-EOS + "\n" + ppm2
      resources { 'firewall':
        purge => true,
      }
    EOS
    expect(apply_manifest(ppm, :catch_failures => true).exit_code).to eq(2)
  end

  it 'test chain - changing names' do
    iptables_flush_all_tables

    ppm1 = <<-EOS
    firewall { '004 with a chain':
      chain => 'INPUT',
      proto => 'all',
    }
    EOS

    ppm2 = <<-EOS
    firewall { '004 with a chain':
      chain => 'OUTPUT',
      proto => 'all',
    }
    EOS

    apply_manifest(ppm1, :expect_changes => true)

    ppm = <<-EOS + "\n" + ppm2
      resources { 'firewall':
        purge => true,
      }
    EOS
    expect(apply_manifest(ppm2, :expect_failures => true).stderr).to match(/is not supported/)
  end

  it 'test log rule - idempotent' do
    iptables_flush_all_tables

    ppm1 = <<-EOS
    firewall { '004 log all INVALID packets':
      chain      => 'INPUT',
      proto      => 'all',
      ctstate    => 'INVALID',
      jump       => 'LOG',
      log_level  => '3',
      log_prefix => 'IPTABLES dropped invalid: ',
    }
    EOS

    expect(apply_manifest(ppm1, :catch_failures => true).exit_code).to eq(2)
    expect(apply_manifest(ppm1, :catch_failures => true).exit_code).to be_zero
  end

  it 'test src_range rule' do
    iptables_flush_all_tables

    ppm = <<-EOS
    firewall { '997 block src ip range':
      chain     => 'INPUT',
      proto     => 'all',
      action    => 'drop',
      src_range => '10.0.0.1-10.0.0.10',
    }
    EOS

    expect(apply_manifest(ppm, :catch_failures => true).exit_code).to eq(2)
    expect(apply_manifest(ppm, :catch_failures => true).exit_code).to be_zero
  end

  it 'test dst_range rule' do
    iptables_flush_all_tables

    ppm = <<-EOS
    firewall { '998 block dst ip range':
      chain     => 'INPUT',
      proto     => 'all',
      action    => 'drop',
      dst_range => '10.0.0.2-10.0.0.20',
    }
    EOS

    expect(apply_manifest(ppm, :catch_failures => true).exit_code).to eq(2)
    expect(apply_manifest(ppm, :catch_failures => true).exit_code).to be_zero
  end

end
