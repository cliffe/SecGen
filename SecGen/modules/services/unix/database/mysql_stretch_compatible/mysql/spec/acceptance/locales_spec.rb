require 'spec_helper_acceptance'
require 'beaker/i18n_helper'

describe 'mysql localization', if: (fact('osfamily') == 'Debian' || fact('osfamily') == 'RedHat') && (Gem::Version.new(puppet_version) >= Gem::Version.new('4.10.5')) do
  before :all do
    hosts.each do |host|
      on(host, "sed -i \"96i FastGettext.locale='ja'\" /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet.rb")
      change_locale_on(host, 'ja_JP.utf-8')
    end
  end

  context 'when triggering puppet simple string error' do
    # 'service_enabled' being set to false can cause random failures in Debian 9
    let(:os_variant) do
      if fact('operatingsystem') =~ %r{Debian} && fact('operatingsystemrelease') =~ %r{^9\.}
        'true'
      else
        'false'
      end
    end
    let(:pp) do
      <<-MANIFEST
    class { 'mysql::server':
            config_file             => '/tmp/mysql.sFlJdV/my.cnf',
            includedir              => '/tmp/mysql.sFlJdV/include',
            manage_config_file      => 'true',
            override_options        => { 'mysqld' => { 'key_buffer_size' => '32M' }},
            package_ensure          => 'present',
            purge_conf_dir          => 'true',
            remove_default_accounts => 'true',
            restart                 => 'true',
            root_group              => 'root',
            root_password           => 'test',
            old_root_password       => 'kittensnmittens',
            service_enabled         => '#{os_variant}',
          }
      MANIFEST
    end

    it 'displays Japanese error' do
      execute_manifest(pp, catch_error: true) do |r|
        expect(r.stderr).to match(%r{`old_root_password`属性は廃止予定であり、今後のリリースで廃止されます。}i)
      end
    end
  end

  context 'when triggering puppet interpolated string failure' do
    let(:pp) do
      <<-MANIFEST
    class { 'mysql::server': root_password => 'password' }
    class { 'mysql::server::backup':
              backupuser     => 'myuser',
              backuppassword => 'mypassword',
              backupdir      => '/tmp/backups',
              backupcompress => true,
              prescript      => true,
              provider       => 'mysqldump',
              execpath       => '/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin',
          }
      MANIFEST
    end

    it 'displays Japanese failure' do
      execute_manifest(pp, catch_failures: true) do |r|
        expect(r.stderr).to match(%r{'prescript'オプションは、現在、mysqldumpバックアッププロバイダ向けには実装されていません。}i)
      end
    end
  end

  context 'when triggering ruby simple string failure' do
    let(:pp) do
      <<-MANIFEST
      mysql::db { 'mydb':
        user     => 'thisisalongusernametestfortodayandtomorrowandthenextdayandthedayafteeeeeeerrrrrrrrrrrrrrr',
        password => 'mypass',
        host     => 'localhost',
        grant    => ['SELECT', 'UPDATE'],
      }
    MANIFEST
    end

    it 'displays Japanese failure' do
      execute_manifest(pp, expect_failures: true) do |r|
        expect(r.stderr).to match(%r{MySQLユーザ名は最大\d{2}文字に制限されています。}i)
      end
    end
  end

  context 'when triggering ruby interpolated string error' do
    let(:pp) do
      <<-MANIFEST
      mysql_user{ '"name@localhost':
        ensure => 'present',
       }
      MANIFEST
    end

    it 'displays Japanese error' do
      execute_manifest(pp, expect_failures: true) do |r|
        expect(r.stderr).to match(%r{無効なデータベースのユーザ"name@localhost}i)
      end
    end
  end

  after :all do
    hosts.each do |host|
      on(host, 'sed -i "96d" /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet.rb')
      change_locale_on(host, 'en_US')
    end
  end
end
