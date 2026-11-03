require 'spec_helper_acceptance'
require 'puppet/util/package'
require_relative './mysql_helper.rb'

describe 'mysql::server::backup class' do
  context 'should work with no errors' do
    pp = <<-MANIFEST
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
    MANIFEST
    it 'when configuring mysql backups' do
      execute_manifest(pp, catch_failures: true)
      execute_manifest(pp, catch_failures: true)
    end
  end

  describe 'mysqlbackup.sh' do
    before(:all) do
      pre_run
    end

    it 'runs mysqlbackup.sh with no errors' do
      unless version_is_greater_than('5.7.0')
        shell('/usr/local/sbin/mysqlbackup.sh') do |r|
          expect(r.stderr).to eq('')
        end
      end
    end

    it 'dumps all databases to single file' do
      unless version_is_greater_than('5.7.0')
        shell('ls -l /tmp/backups/mysql_backup_*-*.sql.bz2 | wc -l') do |r|
          expect(r.stdout).to match(%r{1})
          expect(r.exit_code).to be_zero
        end
      end
    end

    context 'should create one file per database per run' do
      it 'executes mysqlbackup.sh a second time' do
        unless version_is_greater_than('5.7.0')
          shell('sleep 1')
          shell('/usr/local/sbin/mysqlbackup.sh')
        end
      end

      it 'creates at least one backup tarball' do
        unless version_is_greater_than('5.7.0')
          shell('ls -l /tmp/backups/mysql_backup_*-*.sql.bz2 | wc -l') do |r|
            expect(r.stdout).to match(%r{2})
            expect(r.exit_code).to be_zero
          end
        end
      end
    end
    # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
  end

  context 'with one file per database' do
    context 'should work with no errors' do
      pp = <<-MANIFEST
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
      MANIFEST
      it 'when configuring mysql backups' do
        execute_manifest(pp, catch_failures: true)
        execute_manifest(pp, catch_failures: true)
      end
    end

    describe 'mysqlbackup.sh' do
      before(:all) do
        pre_run
      end

      it 'runs mysqlbackup.sh with no errors without root credentials' do
        unless version_is_greater_than('5.7.0')
          shell('HOME=/tmp/dontreadrootcredentials /usr/local/sbin/mysqlbackup.sh') do |r|
            expect(r.stderr).to eq('')
          end
        end
      end

      it 'creates one file per database' do
        unless version_is_greater_than('5.7.0')
          ['backup1', 'backup2'].each do |database|
            shell("ls -l /tmp/backups/mysql_backup_#{database}_*-*.sql.bz2 | wc -l") do |r|
              expect(r.stdout).to match(%r{1})
              expect(r.exit_code).to be_zero
            end
          end
        end
      end

      it 'executes mysqlbackup.sh a second time' do
        unless version_is_greater_than('5.7.0')
          shell('sleep 1')
          shell('HOME=/tmp/dontreadrootcredentials /usr/local/sbin/mysqlbackup.sh')
        end
      end

      it 'has one file per database per run' do
        unless version_is_greater_than('5.7.0')
          ['backup1', 'backup2'].each do |database|
            shell("ls -l /tmp/backups/mysql_backup_#{database}_*-*.sql.bz2 | wc -l") do |r|
              expect(r.stdout).to match(%r{2})
              expect(r.exit_code).to be_zero
            end
          end
        end
      end
      # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
    end
  end

  context 'with triggers and routines' do
    pre_run
    pp = <<-MANIFEST
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
    MANIFEST
    it 'when configuring mysql backups with triggers and routines' do
      execute_manifest(pp, catch_failures: true)
    end

    it 'runs mysqlbackup.sh with no errors' do
      pre_run
      unless version_is_greater_than('5.7.0')
        shell('/usr/local/sbin/mysqlbackup.sh') do |r|
          expect(r.stderr).to eq('')
        end
      end
    end
  end
end
