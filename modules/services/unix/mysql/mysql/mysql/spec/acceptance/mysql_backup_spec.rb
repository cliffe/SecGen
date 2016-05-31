require 'spec_helper_acceptance'
require 'puppet'
require 'puppet/util/package'

describe 'mysql::server::backup class' do

  def pre_run
    apply_manifest("class { 'mysql::server': root_password => 'password' }", :catch_failures => true)
    @mysql_version = (on default, 'mysql --version').output.chomp.match(/\d+\.\d+\.\d+/)[0]
  end

  def version_is_greater_than(version)
    return Puppet::Util::Package.versioncmp(@mysql_version, version) > 0
  end

  context 'should work with no errors' do
    it 'when configuring mysql backups' do
      pp = <<-EOS
        class { 'mysql::server': root_password => 'password' }
        mysql::db { [
          'backup1',
          'backup2'
        ]:
          user     => 'backup',
          password => 'secret',
        }

        class { 'mysql::server::backup':
          backupuser     => 'myuser',
          backuppassword => 'mypassword',
          backupdir      => '/tmp/backups',
          backupcompress => true,
          postscript     => [
            'rm -rf /var/tmp/mysqlbackups',
            'rm -f /var/tmp/mysqlbackups.done',
            'cp -r /tmp/backups /var/tmp/mysqlbackups',
            'touch /var/tmp/mysqlbackups.done',
          ],
          execpath      => '/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_failures => true)
    end
  end

  describe 'mysqlbackup.sh' do
    it 'should run mysqlbackup.sh with no errors' do
      shell("/usr/local/sbin/mysqlbackup.sh") do |r|
        expect(r.stderr).to eq("")
      end
    end

    it 'should dump all databases to single file' do
      shell('ls -l /tmp/backups/mysql_backup_*-*.sql.bz2 | wc -l') do |r|
        expect(r.stdout).to match(/1/)
        expect(r.exit_code).to be_zero
      end
    end

    context 'should create one file per database per run' do
      it 'executes mysqlbackup.sh a second time' do
        shell('sleep 1')
        shell('/usr/local/sbin/mysqlbackup.sh')
      end

      it 'creates at least one backup tarball' do
        shell('ls -l /tmp/backups/mysql_backup_*-*.sql.bz2 | wc -l') do |r|
          expect(r.stdout).to match(/2/)
          expect(r.exit_code).to be_zero
        end
      end
    end
  end

  context 'with one file per database' do
    context 'should work with no errors' do
      it 'when configuring mysql backups' do
        pp = <<-EOS
          class { 'mysql::server': root_password => 'password' }
          mysql::db { [
            'backup1',
            'backup2'
          ]:
            user     => 'backup',
            password => 'secret',
          }

          class { 'mysql::server::backup':
            backupuser        => 'myuser',
            backuppassword    => 'mypassword',
            backupdir         => '/tmp/backups',
            backupcompress    => true,
            file_per_database => true,
            postscript        => [
              'rm -rf /var/tmp/mysqlbackups',
              'rm -f /var/tmp/mysqlbackups.done',
              'cp -r /tmp/backups /var/tmp/mysqlbackups',
              'touch /var/tmp/mysqlbackups.done',
            ],
            execpath          => '/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin',
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_failures => true)
      end
    end

    describe 'mysqlbackup.sh' do
      it 'should run mysqlbackup.sh with no errors without root credentials' do
        shell("HOME=/tmp/dontreadrootcredentials /usr/local/sbin/mysqlbackup.sh") do |r|
          expect(r.stderr).to eq("")
        end
      end

      it 'should create one file per database' do
        ['backup1', 'backup2'].each do |database|
          shell("ls -l /tmp/backups/mysql_backup_#{database}_*-*.sql.bz2 | wc -l") do |r|
            expect(r.stdout).to match(/1/)
            expect(r.exit_code).to be_zero
          end
        end
      end

      context 'should create one file per database per run' do
        it 'executes mysqlbackup.sh a second time' do
          shell('sleep 1')
          shell('HOME=/tmp/dontreadrootcredentials /usr/local/sbin/mysqlbackup.sh')
        end

        it 'has one file per database per run' do
          ['backup1', 'backup2'].each do |database|
            shell("ls -l /tmp/backups/mysql_backup_#{database}_*-*.sql.bz2 | wc -l") do |r|
              expect(r.stdout).to match(/2/)
              expect(r.exit_code).to be_zero
            end
          end
        end
      end
    end
  end

  context 'with triggers and routines' do
    it 'when configuring mysql backups with triggers and routines' do
      pre_run
      pp = <<-EOS
        class { 'mysql::server': root_password => 'password' }
        mysql::db { [
          'backup1',
          'backup2'
          ]:
          user => 'backup',
          password => 'secret',
        }
        package { 'bzip2':
          ensure => present,
        }
        class { 'mysql::server::backup':
          backupuser => 'myuser',
          backuppassword => 'mypassword',
          backupdir => '/tmp/backups',
          backupcompress => true,
          file_per_database => true,
          include_triggers => #{version_is_greater_than('5.1.5')},
          include_routines => true,
          postscript => [
            'rm -rf /var/tmp/mysqlbackups',
            'rm -f /var/tmp/mysqlbackups.done',
            'cp -r /tmp/backups /var/tmp/mysqlbackups',
            'touch /var/tmp/mysqlbackups.done',
          ],
          execpath => '/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin',
          require => Package['bzip2'],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    it 'should run mysqlbackup.sh with no errors' do
      shell("/usr/local/sbin/mysqlbackup.sh") do |r|
        expect(r.stderr).to eq("")
      end
    end
  end
end
