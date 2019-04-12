require 'spec_helper_acceptance'

describe 'mysql::db define' do
  describe 'creating a database' do
    let(:pp) do
      <<-MANIFEST
        class { 'mysql::server': root_password => 'password' }
        mysql::db { 'spec1':
          user     => 'root1',
          password => 'password',
        }
      MANIFEST
    end

    it_behaves_like 'a idempotent resource'

    describe command("mysql -e 'show databases;'") do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match %r{^spec1$} }
    end
  end

  describe 'creating a database with post-sql' do
    let(:pp) do
      <<-MANIFEST
        class { 'mysql::server': override_options => { 'root_password' => 'password' } }
        file { '/tmp/spec.sql':
          ensure  => file,
          content => 'CREATE TABLE table1 (id int);',
          before  => Mysql::Db['spec2'],
        }
        mysql::db { 'spec2':
          user     => 'root1',
          password => 'password',
          sql      => '/tmp/spec.sql',
        }
      MANIFEST
    end

    it_behaves_like 'a idempotent resource'

    describe command("mysql -e 'show tables;' spec2") do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match %r{^table1$} }
    end
  end

  describe 'creating a database with dbname parameter' do
    let(:check_command) { ' | grep realdb' }
    let(:pp) do
      <<-MANIFEST
        class { 'mysql::server': override_options => { 'root_password' => 'password' } }
        mysql::db { 'spec1':
          user     => 'root1',
          password => 'password',
          dbname   => 'realdb',
        }
      MANIFEST
    end

    it_behaves_like 'a idempotent resource'

    describe command("mysql -e 'show databases;'") do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match %r{^realdb$} }
    end
  end
end
