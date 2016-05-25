require 'spec_helper'

describe Puppet::Type.type(:mysql_user).provider(:mysql) do

  # Output of mysqld -V
  mysql_version_string_hash = {
      'mysql-5.5' => 
      {
        :version => '5.5.46',
        :string => '/usr/sbin/mysqld  Ver 5.5.46-log for Linux on x86_64 (MySQL Community Server (GPL))',
        :mysql_type => 'mysql',
      },
      'mysql-5.6' => 
      {
        :version => '5.6.27',
        :string => '/usr/sbin/mysqld  Ver 5.6.27 for Linux on x86_64 (MySQL Community Server (GPL))',
        :mysql_type => 'mysql',
      },
      'mysql-5.7.1' => 
      {
        :version => '5.7.1',
        :string => '/usr/sbin/mysqld  Ver 5.7.1 for Linux on x86_64 (MySQL Community Server (GPL))',
        :mysql_type => 'mysql',
      },
      'mysql-5.7.6' => 
      {
        :version => '5.7.8',
        :string => '/usr/sbin/mysqld  Ver 5.7.8-rc for Linux on x86_64 (MySQL Community Server (GPL))',
        :mysql_type => 'mysql',
      },
      'mariadb-10.0' =>
      {
        :version => '10.0.21',
        :string => '/usr/sbin/mysqld  Ver 10.0.21-MariaDB for Linux on x86_64 (MariaDB Server)',
        :mysql_type => 'mariadb',
      },
      'percona-5.5' =>
      {
        :version => '5.5.39',
        :string => 'mysqld  Ver 5.5.39-36.0-55 for Linux on x86_64 (Percona XtraDB Cluster (GPL), Release rel36.0, Revision 824, WSREP version 25.11, wsrep_25.11.r4023)',
        :mysql_type => 'percona',
      },
    }

  let(:defaults_file) { '--defaults-extra-file=/root/.my.cnf' }
  let(:newhash) { '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5' }

  let(:raw_users) do
    <<-SQL_OUTPUT
root@127.0.0.1
root@::1
@localhost
debian-sys-maint@localhost
root@localhost
usvn_user@localhost
@vagrant-ubuntu-raring-64
    SQL_OUTPUT
  end

  let(:parsed_users) { %w(root@127.0.0.1 root@::1 @localhost debian-sys-maint@localhost root@localhost usvn_user@localhost @vagrant-ubuntu-raring-64) }

  let(:resource) { Puppet::Type.type(:mysql_user).new(
      { :ensure                   => :present,
        :password_hash            => '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4',
        :name                     => 'joe@localhost',
        :max_user_connections     => '10',
        :max_connections_per_hour => '10',
        :max_queries_per_hour     => '10',
        :max_updates_per_hour     => '10',
        :provider                 => described_class.name
      }
  )}
  let(:provider) { resource.provider }

  before :each do
    # Set up the stubs for an instances call.
    Facter.stubs(:value).with(:root_home).returns('/root')
    Facter.stubs(:value).with(:mysql_version).returns('5.6.24')
    provider.class.instance_variable_set(:@mysqld_version_string, '5.6.24')
    Puppet::Util.stubs(:which).with('mysql').returns('/usr/bin/mysql')
    Puppet::Util.stubs(:which).with('mysqld').returns('/usr/sbin/mysqld')
    File.stubs(:file?).with('/root/.my.cnf').returns(true)
    provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT CONCAT(User, '@',Host) AS User FROM mysql.user"]).returns('joe@localhost')
    provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT MAX_USER_CONNECTIONS, MAX_CONNECTIONS, MAX_QUESTIONS, MAX_UPDATES, PASSWORD /*!50508 , PLUGIN */ FROM mysql.user WHERE CONCAT(user, '@', host) = 'joe@localhost'"]).returns('10 10 10 10 *6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4')
  end

  let(:instance) { provider.class.instances.first }

  describe 'self.instances' do
    it 'returns an array of users MySQL 5.5' do
      provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['mysql-5.5'][:string])
      provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT CONCAT(User, '@',Host) AS User FROM mysql.user"]).returns(raw_users)
      parsed_users.each do |user|
        provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT MAX_USER_CONNECTIONS, MAX_CONNECTIONS, MAX_QUESTIONS, MAX_UPDATES, PASSWORD /*!50508 , PLUGIN */ FROM mysql.user WHERE CONCAT(user, '@', host) = '#{user}'"]).returns('10 10 10 10 ')
      end

      usernames = provider.class.instances.collect {|x| x.name }
      expect(parsed_users).to match_array(usernames)
    end
    it 'returns an array of users MySQL 5.6' do
      provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['mysql-5.6'][:string])
      provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT CONCAT(User, '@',Host) AS User FROM mysql.user"]).returns(raw_users)
      parsed_users.each do |user|
        provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT MAX_USER_CONNECTIONS, MAX_CONNECTIONS, MAX_QUESTIONS, MAX_UPDATES, PASSWORD /*!50508 , PLUGIN */ FROM mysql.user WHERE CONCAT(user, '@', host) = '#{user}'"]).returns('10 10 10 10 ')
      end

      usernames = provider.class.instances.collect {|x| x.name }
      expect(parsed_users).to match_array(usernames)
    end
    it 'returns an array of users MySQL >= 5.7.0 < 5.7.6' do
      provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['mysql-5.7.1'][:string])
      provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT CONCAT(User, '@',Host) AS User FROM mysql.user"]).returns(raw_users)
      parsed_users.each do |user|
        provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT MAX_USER_CONNECTIONS, MAX_CONNECTIONS, MAX_QUESTIONS, MAX_UPDATES, PASSWORD /*!50508 , PLUGIN */ FROM mysql.user WHERE CONCAT(user, '@', host) = '#{user}'"]).returns('10 10 10 10 ')
      end

      usernames = provider.class.instances.collect {|x| x.name }
      expect(parsed_users).to match_array(usernames)
    end
    it 'returns an array of users MySQL >= 5.7.6' do
      provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['mysql-5.7.6'][:string])
      provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT CONCAT(User, '@',Host) AS User FROM mysql.user"]).returns(raw_users)
      parsed_users.each do |user|
        provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT MAX_USER_CONNECTIONS, MAX_CONNECTIONS, MAX_QUESTIONS, MAX_UPDATES, AUTHENTICATION_STRING, PLUGIN FROM mysql.user WHERE CONCAT(user, '@', host) = '#{user}'"]).returns('10 10 10 10 ')
      end

      usernames = provider.class.instances.collect {|x| x.name }
      expect(parsed_users).to match_array(usernames)
    end
    it 'returns an array of users mariadb 10.0' do
      provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['mariadb-10.0'][:string])
      provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT CONCAT(User, '@',Host) AS User FROM mysql.user"]).returns(raw_users)
      parsed_users.each do |user|
        provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT MAX_USER_CONNECTIONS, MAX_CONNECTIONS, MAX_QUESTIONS, MAX_UPDATES, PASSWORD /*!50508 , PLUGIN */ FROM mysql.user WHERE CONCAT(user, '@', host) = '#{user}'"]).returns('10 10 10 10 ')
      end

      usernames = provider.class.instances.collect {|x| x.name }
      expect(parsed_users).to match_array(usernames)
    end
    it 'returns an array of users percona 5.5' do
      provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['percona-5.5'][:string])
      provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT CONCAT(User, '@',Host) AS User FROM mysql.user"]).returns(raw_users)
      parsed_users.each do |user|
        provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT MAX_USER_CONNECTIONS, MAX_CONNECTIONS, MAX_QUESTIONS, MAX_UPDATES, PASSWORD /*!50508 , PLUGIN */ FROM mysql.user WHERE CONCAT(user, '@', host) = '#{user}'"]).returns('10 10 10 10 ')
      end

      usernames = provider.class.instances.collect {|x| x.name }
      expect(parsed_users).to match_array(usernames)
    end
  end

  describe 'mysql version and type detection' do
    mysql_version_string_hash.each do |name,line|
      version=line[:version]
      string=line[:string]
      mysql_type=line[:mysql_type]
      it "detects type '#{mysql_type}' with version '#{version}'" do
        provider.class.instance_variable_set(:@mysqld_version_string, string)
        expect(provider.mysqld_version).to eq(version)
        expect(provider.mysqld_type).to eq(mysql_type)
      end
    end
  end

  describe 'self.prefetch' do
    it 'exists' do
      provider.class.instances
      provider.class.prefetch({})
    end
  end

  describe 'create' do
    it 'makes a user' do
      provider.expects(:mysql).with([defaults_file, '-e', "CREATE USER 'joe'@'localhost' IDENTIFIED BY PASSWORD '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4'"])
      provider.expects(:mysql).with([defaults_file, '-e', "GRANT USAGE ON *.* TO 'joe'@'localhost' WITH MAX_USER_CONNECTIONS 10 MAX_CONNECTIONS_PER_HOUR 10 MAX_QUERIES_PER_HOUR 10 MAX_UPDATES_PER_HOUR 10"])
      provider.expects(:exists?).returns(true)
      expect(provider.create).to be_truthy
    end
  end

  describe 'destroy' do
    it 'removes a user if present' do
      provider.expects(:mysql).with([defaults_file, '-e', "DROP USER 'joe'@'localhost'"])
      provider.expects(:exists?).returns(false)
      expect(provider.destroy).to be_truthy
    end
  end

  describe 'exists?' do
    it 'checks if user exists' do
      expect(instance.exists?).to be_truthy
    end
  end

  describe 'self.mysqld_version' do
    it 'queries mysql if unset' do
       provider.class.instance_variable_set(:@mysqld_version_string, nil)
       provider.class.expects(:mysqld).with(['-V'])
       expect(provider.mysqld_version).to be_nil
    end
    it 'returns 5.7.6 for "mysqld  Ver 5.7.6 for Linux on x86_64 (MySQL Community Server (GPL))"' do
       provider.class.instance_variable_set(:@mysqld_version_string, 'mysqld  Ver 5.7.6 for Linux on x86_64 (MySQL Community Server (GPL))')
       expect(provider.mysqld_version).to eq '5.7.6'
    end
    it 'returns 5.7.6 for "mysqld  Ver 5.7.6-rc for Linux on x86_64 (MySQL Community Server (GPL))"' do
       provider.class.instance_variable_set(:@mysqld_version_string, 'mysqld  Ver 5.7.6-rc for Linux on x86_64 (MySQL Community Server (GPL))')
       expect(provider.mysqld_version).to eq '5.7.6'
    end
    it 'detects >= 5.7.6 for 5.7.7-log' do
       provider.class.instance_variable_set(:@mysqld_version_string, 'mysqld  Ver 5.7.7-log for Linux on x86_64 (MySQL Community Server (GPL))')
       expect(Puppet::Util::Package.versioncmp(provider.mysqld_version, '5.7.6')).to be >= 0
    end
    it 'detects < 5.7.6 for 5.7.5-log' do
       provider.class.instance_variable_set(:@mysqld_version_string, 'mysqld  Ver 5.7.5-log for Linux on x86_64 (MySQL Community Server (GPL))')
       expect(Puppet::Util::Package.versioncmp(provider.mysqld_version, '5.7.6')).to be < 0
    end
  end

  describe 'self.defaults_file' do
    it 'sets --defaults-extra-file' do
      File.stubs(:file?).with('/root/.my.cnf').returns(true)
      expect(provider.defaults_file).to eq '--defaults-extra-file=/root/.my.cnf'
    end
    it 'fails if file missing' do
      File.expects(:file?).with('/root/.my.cnf').returns(false)
      expect(provider.defaults_file).to be_nil
    end
  end

  describe 'password_hash' do
    it 'returns a hash' do
      expect(instance.password_hash).to eq('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4')
    end
  end

  describe 'password_hash=' do
    it 'changes the hash mysql 5.5' do
      provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['mysql-5.5'][:string])
      provider.expects(:mysql).with([defaults_file, '-e', "SET PASSWORD FOR 'joe'@'localhost' = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'"]).returns('0')

      provider.expects(:password_hash).returns('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
      provider.password_hash=('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
    end
    it 'changes the hash mysql 5.6' do
      provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['mysql-5.6'][:string])
      provider.expects(:mysql).with([defaults_file, '-e', "SET PASSWORD FOR 'joe'@'localhost' = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'"]).returns('0')

      provider.expects(:password_hash).returns('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
      provider.password_hash=('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
    end
    it 'changes the hash mysql < 5.7.6' do
      provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['mysql-5.7.1'][:string])
      provider.expects(:mysql).with([defaults_file, '-e', "SET PASSWORD FOR 'joe'@'localhost' = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'"]).returns('0')

      provider.expects(:password_hash).returns('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
      provider.password_hash=('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
    end
    it 'changes the hash MySQL >= 5.7.6' do
      provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['mysql-5.7.6'][:string])
      provider.expects(:mysql).with([defaults_file, '-e', "ALTER USER 'joe'@'localhost' IDENTIFIED WITH mysql_native_password AS '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'"]).returns('0')

      provider.expects(:password_hash).returns('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
      provider.password_hash=('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
    end
    it 'changes the hash mariadb-10.0' do
      provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['mariadb-10.0'][:string])
      provider.expects(:mysql).with([defaults_file, '-e', "SET PASSWORD FOR 'joe'@'localhost' = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'"]).returns('0')

      provider.expects(:password_hash).returns('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
      provider.password_hash=('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
    end
    it 'changes the hash percona-5.5' do
      provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['percona-5.5'][:string])
      provider.expects(:mysql).with([defaults_file, '-e', "SET PASSWORD FOR 'joe'@'localhost' = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'"]).returns('0')

      provider.expects(:password_hash).returns('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
      provider.password_hash=('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
    end
  end

  ['max_user_connections', 'max_connections_per_hour', 'max_queries_per_hour',
   'max_updates_per_hour'].each do |property|

    describe property do
      it "returns #{property}" do
        expect(instance.send("#{property}".to_sym)).to eq('10')
      end
    end

    describe "#{property}=" do
      it "changes #{property}" do
        provider.expects(:mysql).with([defaults_file, '-e', "GRANT USAGE ON *.* TO 'joe'@'localhost' WITH #{property.upcase} 42"]).returns('0')
        provider.expects(property.to_sym).returns('42')
        provider.send("#{property}=".to_sym, '42')
      end
    end
  end

end
