require 'spec_helper'

describe 'mysql::server::backup' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) do
        <<-EOF
          class { 'mysql::server': }
        EOF
      end
      let(:facts) do
        facts.merge(root_home: '/root')
      end

      let(:default_params) do
        { 'backupuser'         => 'testuser',
          'backuppassword'     => 'testpass',
          'backupdir'          => '/tmp',
          'backuprotate'       => '25',
          'delete_before_dump' => true,
          'execpath'           => '/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin',
          'maxallowedpacket'   => '1M' }
      end

      context 'standard conditions' do
        let(:params) { default_params }

        # Cannot use that_requires here, doesn't work on classes.
        it {
          is_expected.to contain_mysql_user('testuser@localhost').with(
            require: 'Class[Mysql::Server::Root_password]',
          )
        }

        it {
          is_expected.to contain_mysql_grant('testuser@localhost/*.*').with(
            privileges: ['SELECT', 'RELOAD', 'LOCK TABLES', 'SHOW VIEW', 'PROCESS'],
          ).that_requires('Mysql_user[testuser@localhost]')
        }

        context 'with triggers included' do
          let(:params) do
            { include_triggers: true }.merge(default_params)
          end

          it {
            is_expected.to contain_mysql_grant('testuser@localhost/*.*').with(
              privileges: ['SELECT', 'RELOAD', 'LOCK TABLES', 'SHOW VIEW', 'PROCESS', 'TRIGGER'],
            ).that_requires('Mysql_user[testuser@localhost]')
          }
        end

        it {
          is_expected.to contain_cron('mysql-backup').with(
            command: '/usr/local/sbin/mysqlbackup.sh',
            ensure: 'present',
          )
        }

        it {
          is_expected.to contain_file('mysqlbackup.sh').with(
            path: '/usr/local/sbin/mysqlbackup.sh',
            ensure: 'present',
          )
        }

        it {
          is_expected.to contain_file('mysqlbackupdir').with(
            path: '/tmp',
            ensure: 'directory',
          )
        }

        it 'has compression by default' do
          is_expected.to contain_file('mysqlbackup.sh').with_content(
            %r{bzcat -zc},
          )
        end

        it 'skips backing up events table by default' do
          is_expected.to contain_file('mysqlbackup.sh').with_content(
            %r{ADDITIONAL_OPTIONS="--ignore-table=mysql.event"},
          )
        end

        it 'does not mention triggers by default because file_per_database is false' do
          is_expected.to contain_file('mysqlbackup.sh').without_content(
            %r{.*triggers.*},
          )
        end

        it 'does not mention routines by default because file_per_database is false' do
          is_expected.to contain_file('mysqlbackup.sh').without_content(
            %r{.*routines.*},
          )
        end

        it 'has 25 days of rotation' do
          # MySQL counts from 0
          is_expected.to contain_file('mysqlbackup.sh').with_content(%r{.*ROTATE=24.*})
        end

        it 'has a standard PATH' do
          is_expected.to contain_file('mysqlbackup.sh').with_content(%r{PATH=/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin})
        end
      end

      context 'custom ownership and mode for backupdir' do
        let(:params) do
          { backupdirmode: '0750',
            backupdirowner: 'testuser',
            backupdirgroup: 'testgrp' }.merge(default_params)
        end

        it {
          is_expected.to contain_file('mysqlbackupdir').with(
            path: '/tmp', ensure: 'directory',
            mode: '0750', owner: 'testuser',
            group: 'testgrp'
          )
        }
      end

      context 'with compression disabled' do
        let(:params) do
          { backupcompress: false }.merge(default_params)
        end

        it {
          is_expected.to contain_file('mysqlbackup.sh').with(
            path: '/usr/local/sbin/mysqlbackup.sh',
            ensure: 'present',
          )
        }

        it 'is able to disable compression' do
          is_expected.to contain_file('mysqlbackup.sh').without_content(
            %r{.*bzcat -zc.*},
          )
        end
      end

      context 'with mysql.events backedup' do
        let(:params) do
          { ignore_events: false }.merge(default_params)
        end

        it {
          is_expected.to contain_file('mysqlbackup.sh').with(
            path: '/usr/local/sbin/mysqlbackup.sh',
            ensure: 'present',
          )
        }

        it 'is able to backup events table' do
          is_expected.to contain_file('mysqlbackup.sh').with_content(
            %r{ADDITIONAL_OPTIONS="--events"},
          )
        end
      end

      context 'with database list specified' do
        let(:params) do
          { backupdatabases: ['mysql'] }.merge(default_params)
        end

        it {
          is_expected.to contain_file('mysqlbackup.sh').with(
            path: '/usr/local/sbin/mysqlbackup.sh',
            ensure: 'present',
          )
        }

        it 'has a backup file for each database' do
          is_expected.to contain_file('mysqlbackup.sh').with_content(
            %r{mysql | bzcat -zc \${DIR}\\\${PREFIX}mysql_`date'},
          )
        end

        it 'skips backup triggers by default' do
          is_expected.to contain_file('mysqlbackup.sh').with_content(
            %r{ADDITIONAL_OPTIONS="\$ADDITIONAL_OPTIONS --skip-triggers"},
          )
        end

        it 'skips backing up routines by default' do
          is_expected.to contain_file('mysqlbackup.sh').with_content(
            %r{ADDITIONAL_OPTIONS="\$ADDITIONAL_OPTIONS --skip-routines"},
          )
        end

        context 'with include_triggers set to true' do
          let(:params) do
            default_params.merge(backupdatabases: ['mysql'],
                                 include_triggers: true)
          end

          it 'backups triggers when asked' do
            is_expected.to contain_file('mysqlbackup.sh').with_content(
              %r{ADDITIONAL_OPTIONS="\$ADDITIONAL_OPTIONS --triggers"},
            )
          end
        end

        context 'with include_triggers set to false' do
          let(:params) do
            default_params.merge(backupdatabases: ['mysql'],
                                 include_triggers: false)
          end

          it 'skips backing up triggers when asked to skip' do
            is_expected.to contain_file('mysqlbackup.sh').with_content(
              %r{ADDITIONAL_OPTIONS="\$ADDITIONAL_OPTIONS --skip-triggers"},
            )
          end
        end

        context 'with include_routines set to true' do
          let(:params) do
            default_params.merge(backupdatabases: ['mysql'],
                                 include_routines: true)
          end

          it 'backups routines when asked' do
            is_expected.to contain_file('mysqlbackup.sh').with_content(
              %r{ADDITIONAL_OPTIONS="\$ADDITIONAL_OPTIONS --routines"},
            )
          end
        end

        context 'with include_routines set to false' do
          let(:params) do
            default_params.merge(backupdatabases: ['mysql'],
                                 include_triggers: true)
          end

          it 'skips backing up routines when asked to skip' do
            is_expected.to contain_file('mysqlbackup.sh').with_content(
              %r{ADDITIONAL_OPTIONS="\$ADDITIONAL_OPTIONS --skip-routines"},
            )
          end
        end
      end

      context 'with file per database' do
        let(:params) do
          default_params.merge(file_per_database: true)
        end

        it 'loops through backup all databases' do
          is_expected.to contain_file('mysqlbackup.sh').with_content(%r{.*SHOW DATABASES.*})
        end

        context 'with compression disabled' do
          let(:params) do
            default_params.merge(file_per_database: true, backupcompress: false)
          end

          it 'loops through backup all databases without compression #show databases' do
            is_expected.to contain_file('mysqlbackup.sh').with_content(%r{.*SHOW DATABASES.*})
          end
          it 'loops through backup all databases without compression #bzcat' do
            is_expected.to contain_file('mysqlbackup.sh').without_content(%r{.*bzcat -zc.*})
          end
        end

        it 'skips backup triggers by default' do
          is_expected.to contain_file('mysqlbackup.sh').with_content(
            %r{ADDITIONAL_OPTIONS="\$ADDITIONAL_OPTIONS --skip-triggers"},
          )
        end

        it 'skips backing up routines by default' do
          is_expected.to contain_file('mysqlbackup.sh').with_content(
            %r{ADDITIONAL_OPTIONS="\$ADDITIONAL_OPTIONS --skip-routines"},
          )
        end

        context 'with include_triggers set to true' do
          let(:params) do
            default_params.merge(file_per_database: true,
                                 include_triggers: true)
          end

          it 'backups triggers when asked' do
            is_expected.to contain_file('mysqlbackup.sh').with_content(
              %r{ADDITIONAL_OPTIONS="\$ADDITIONAL_OPTIONS --triggers"},
            )
          end
        end

        context 'with include_triggers set to false' do
          let(:params) do
            default_params.merge(file_per_database: true,
                                 include_triggers: false)
          end

          it 'skips backing up triggers when asked to skip' do
            is_expected.to contain_file('mysqlbackup.sh').with_content(
              %r{ADDITIONAL_OPTIONS="\$ADDITIONAL_OPTIONS --skip-triggers"},
            )
          end
        end

        context 'with include_routines set to true' do
          let(:params) do
            default_params.merge(file_per_database: true,
                                 include_routines: true)
          end

          it 'backups routines when asked' do
            is_expected.to contain_file('mysqlbackup.sh').with_content(
              %r{ADDITIONAL_OPTIONS="\$ADDITIONAL_OPTIONS --routines"},
            )
          end
        end

        context 'with include_routines set to false' do
          let(:params) do
            default_params.merge(file_per_database: true,
                                 include_triggers: true)
          end

          it 'skips backing up routines when asked to skip' do
            is_expected.to contain_file('mysqlbackup.sh').with_content(
              %r{ADDITIONAL_OPTIONS="\$ADDITIONAL_OPTIONS --skip-routines"},
            )
          end
        end
      end

      context 'with postscript' do
        let(:params) do
          default_params.merge(postscript: 'rsync -a /tmp backup01.local-lan:')
        end

        it 'is add postscript' do
          is_expected.to contain_file('mysqlbackup.sh').with_content(
            %r{rsync -a \/tmp backup01.local-lan:},
          )
        end
      end

      context 'with postscripts' do
        let(:params) do
          default_params.merge(postscript: [
                                 'rsync -a /tmp backup01.local-lan:',
                                 'rsync -a /tmp backup02.local-lan:',
                               ])
        end

        it 'is add postscript' do
          is_expected.to contain_file('mysqlbackup.sh').with_content(
            %r{.*rsync -a \/tmp backup01.local-lan:\n\nrsync -a \/tmp backup02.local-lan:.*},
          )
        end
      end

      context 'with the xtrabackup provider' do
        let(:params) do
          default_params.merge(provider: 'xtrabackup')
        end

        it 'contains the wrapper script' do
          is_expected.to contain_file('xtrabackup.sh').with_content(
            %r{^innobackupex\s+.*?"\$@"},
          )
        end

        context 'with prescript defined' do
          let(:params) do
            default_params.merge(provider: 'xtrabackup',
                                 prescript: [
                                   'rsync -a /tmp backup01.local-lan:',
                                   'rsync -a /tmp backup02.local-lan:',
                                 ])
          end

          it 'contains the prescript' do
            is_expected.to contain_file('xtrabackup.sh').with_content(
              %r{.*rsync -a \/tmp backup01.local-lan:\n\nrsync -a \/tmp backup02.local-lan:.*},
            )
          end
        end

        context 'with postscript defined' do
          let(:params) do
            default_params.merge(provider: 'xtrabackup',
                                 postscript: [
                                   'rsync -a /tmp backup01.local-lan:',
                                   'rsync -a /tmp backup02.local-lan:',
                                 ])
          end

          it 'contains the prostscript' do
            is_expected.to contain_file('xtrabackup.sh').with_content(
              %r{.*rsync -a \/tmp backup01.local-lan:\n\nrsync -a \/tmp backup02.local-lan:.*},
            )
          end
        end
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups
end
