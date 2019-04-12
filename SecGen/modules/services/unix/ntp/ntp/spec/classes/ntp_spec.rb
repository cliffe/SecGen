require 'spec_helper'

describe 'ntp' do
  let(:facts) {{ :is_virtual => 'false' }}

  ['Debian', 'RedHat', 'Fedora', 'Suse11', 'Suse12', 'FreeBSD', 'Archlinux', 'Gentoo', 'Gentoo (Facter < 1.7)'].each do |system|
    context "when on system #{system}" do
      let :facts do
        case system
        when 'Gentoo (Facter < 1.7)'
          super().merge({ :osfamily => 'Linux', :operatingsystem => 'Gentoo' })
        when 'Suse11'
          super().merge({ :osfamily => 'Suse', :operatingsystem => 'SLES', :operatingsystemmajrelease => '11' })
        when 'Suse12'
          super().merge({ :osfamily => 'Suse', :operatingsystem => 'SLES', :operatingsystemmajrelease => '12' })
        when 'Fedora'
          super().merge({ :osfamily => 'RedHat', :operatingsystem => system, :operatingsystemmajrelease => '22' })
        else
          super().merge({ :osfamily => system, :operatingsystem => system})
        end
      end

      it { should contain_class('ntp::install') }
      it { should contain_class('ntp::config') }
      it { should contain_class('ntp::service') }

      describe "ntp::config on #{system}" do
        it { should contain_file('/etc/ntp.conf').with_owner('0') }
        it { should contain_file('/etc/ntp.conf').with_group('0') }
        it { should contain_file('/etc/ntp.conf').with_mode('0644') }

        if system == 'Suse12'
          it { should contain_file('/var/run/ntp/servers-netconfig').with_ensure_absent }
        end

        describe 'allows template to be overridden' do
          let(:params) {{ :config_template => 'my_ntp/ntp.conf.erb' }}
          it { should contain_file('/etc/ntp.conf').with({
            'content' => /server foobar/})
          }
        end

        describe "keys for osfamily #{system}" do
          context "when enabled" do
            let(:params) {{
              :keys_enable     => true,
              :keys_trusted    => ['1', '2', '3'],
              :keys_controlkey => '2',
              :keys_requestkey => '3',
            }}

            it { should contain_file('/etc/ntp.conf').with({
              'content' => /trustedkey 1 2 3/})
            }
            it { should contain_file('/etc/ntp.conf').with({
              'content' => /controlkey 2/})
            }
            it { should contain_file('/etc/ntp.conf').with({
              'content' => /requestkey 3/})
            }
          end
        end

        context "when disabled" do
          let(:params) {{
            :keys_enable     => false,
            :keys_trusted    => ['1', '2', '3'],
            :keys_controlkey => '2',
            :keys_requestkey => '3',
          }}

          it { should_not contain_file('/etc/ntp.conf').with({
            'content' => /trustedkey 1 2 3/})
          }
          it { should_not contain_file('/etc/ntp.conf').with({
            'content' => /controlkey 2/})
          }
          it { should_not contain_file('/etc/ntp.conf').with({
            'content' => /requestkey 3/})
          }
        end

        describe 'preferred servers' do
          context "when set" do
            let(:params) {{
              :servers           => ['a', 'b', 'c', 'd'],
              :preferred_servers => ['a', 'b'],
              :iburst_enable     => false,
            }}

            it { should contain_file('/etc/ntp.conf').with({
              'content' => /server a prefer( maxpoll 9)?\nserver b prefer( maxpoll 9)?\nserver c( maxpoll 9)?\nserver d( maxpoll 9)?/})
            }
          end
          context "when not set" do
            let(:params) {{
              :servers           => ['a', 'b', 'c', 'd'],
              :preferred_servers => []
            }}

            it { should_not contain_file('/etc/ntp.conf').with({
              'content' => /server a prefer/})
            }
          end
        end
        describe 'specified interfaces' do
          context "when set" do
            let(:params) {{
              :servers           => ['a', 'b', 'c', 'd'],
              :interfaces        => ['127.0.0.1', 'a.b.c.d']
            }}

            it { should contain_file('/etc/ntp.conf').with({
              'content' => /interface ignore wildcard\ninterface listen 127.0.0.1\ninterface listen a.b.c.d/})
            }
          end
          context "when not set" do
            let(:params) {{
              :servers           => ['a', 'b', 'c', 'd'],
            }}

            it { should_not contain_file('/etc/ntp.conf').with({
              'content' => /interface ignore wildcard/})
            }
          end
        end

        describe 'specified ignore interfaces' do
          context "when set" do
            let(:params) {{
              :interfaces => ['a.b.c.d'],
              :interfaces_ignore => ['wildcard', 'ipv6']
            }}

            it { should contain_file('/etc/ntp.conf').with({
              'content' => /interface ignore wildcard\ninterface ignore ipv6\ninterface listen a.b.c.d/})
            }
          end
          context "when not set" do
            let(:params) {{
              :interfaces   => ['127.0.0.1'],
              :servers      => ['a', 'b', 'c', 'd'],
            }}

            it { should contain_file('/etc/ntp.conf').with({
              'content' => /interface ignore wildcard\ninterface listen 127.0.0.1/})
            }
          end
        end

        describe 'with parameter disable_auth' do
          context 'when set to true' do
            let(:params) {{
              :disable_auth => true,
            }}

            it 'should contain disable auth setting' do
              should contain_file('/etc/ntp.conf').with({
              'content' => /^disable auth\n/,
              })
            end
          end
          context 'when set to false' do
            let(:params) {{
              :disable_auth => false,
            }}

            it 'should not contain disable auth setting' do
              should_not contain_file('/etc/ntp.conf').with({
                'content' => /^disable auth\n/,
              })
            end
          end
        end

        describe 'with parameter disable_dhclient' do
          context 'when set to true' do
            let(:params) {{
              :disable_dhclient => true,
            }}

            it 'should contain disable ntp-servers setting' do
              should contain_augeas('disable ntp-servers in dhclient.conf')
            end
            it 'should contain dhcp file' do
              should contain_file('/var/lib/ntp/ntp.conf.dhcp').with_ensure('absent')
            end
          end
          context 'when set to false' do
            let(:params) {{
              :disable_dhclient => false,
            }}

            it 'should not contain disable ntp-servers setting' do
              should_not contain_augeas('disable ntp-servers in dhclient.conf')
            end
            it 'should not contain dhcp file' do
              should_not contain_file('/var/lib/ntp/ntp.conf.dhcp').with_ensure('absent')
            end
          end
        end
        describe 'with parameter disable_kernel' do
          context 'when set to true' do
            let(:params) {{
              :disable_kernel => true,
            }}

            it 'should contain disable kernel setting' do
              should contain_file('/etc/ntp.conf').with({
              'content' => /^disable kernel\n/,
              })
            end
          end
          context 'when set to false' do
            let(:params) {{
              :disable_kernel => false,
            }}

            it 'should not contain disable kernel setting' do
              should_not contain_file('/etc/ntp.conf').with({
              'content' => /^disable kernel\n/,
              })
            end
          end
        end
        describe 'with parameter disable_monitor' do
          context 'default' do
            let(:params) {{
            }}

            it 'should contain disable monitor setting' do
              should contain_file('/etc/ntp.conf').with({
                'content' => /^disable monitor\n/,
              })
            end
          end
          context 'when set to true' do
            let(:params) {{
              :disable_monitor => true,
            }}

            it 'should contain disable monitor setting' do
              should contain_file('/etc/ntp.conf').with({
                'content' => /^disable monitor\n/,
              })
            end
          end
          context 'when set to false' do
            let(:params) {{
              :disable_monitor => false,
            }}

            it 'should not contain disable monitor setting' do
              should_not contain_file('/etc/ntp.conf').with({
                'content' => /^disable monitor\n/,
              })
            end
          end
        end
        describe 'with parameter broadcastclient' do
          context 'when set to true' do
            let(:params) {{
              :broadcastclient => true,
            }}

            it 'should contain broadcastclient setting' do
              should contain_file('/etc/ntp.conf').with({
                'content' => /^broadcastclient\n/,
              })
            end
          end
          context 'when set to false' do
            let(:params) {{
              :broadcastclient => false,
            }}

            it 'should not contain broadcastclient setting' do
              should_not contain_file('/etc/ntp.conf').with({
                'content' => /^broadcastclient\n/,
              })
            end
          end
          context 'when setting custom config_dir' do
            let(:params) {{
              :keys_enable => true,
              :config_dir  => '/tmp/foo',
              :keys_file   => '/tmp/foo/ntp.keys',
            }}

            it 'should contain custom config directory' do
              should contain_file('/tmp/foo').with(
                'ensure'  => 'directory',
                'owner'   => '0',
                'group'   => '0',
                'mode'    => '0775',
                'recurse' => 'false'
              )
            end
          end
          context 'when manually setting conf file mode to 0777' do
            let(:params) {{
              :config_file_mode => '0777',
            }}

            it 'should contain file mode of 0777' do
              should contain_file('/etc/ntp.conf').with_mode('0777')
            end
          end
        end

        describe "ntp::install on #{system}" do
          let(:params) {{ :package_ensure => 'present', :package_name => ['ntp'], :package_manage => true, }}

          it { should contain_package('ntp').with(
            :ensure => 'present'
          )}

          describe 'should allow package ensure to be overridden' do
            let(:params) {{ :package_ensure => 'latest', :package_name => ['ntp'], :package_manage => true, }}
            it { should contain_package('ntp').with_ensure('latest') }
          end

          describe 'should allow the package name to be overridden' do
            let(:params) {{ :package_ensure => 'present', :package_name => ['hambaby'], :package_manage => true, }}
            it { should contain_package('hambaby') }
          end

          describe 'should allow the package to be unmanaged' do
            let(:params) {{ :package_manage => false, :package_name => ['ntp'], }}
            it { should_not contain_package('ntp') }
          end
        end

        describe 'ntp::service' do
          let(:params) {{
            :service_manage => true,
            :service_enable => true,
            :service_ensure => 'running',
            :service_name   => 'ntp'
          }}

          describe 'with defaults' do
            it { should contain_service('ntp').with(
              :enable => true,
              :ensure => 'running',
              :name   => 'ntp'
            )}
          end

          describe 'service_ensure' do
            describe 'when overridden' do
              let(:params) {{ :service_name => 'ntp', :service_ensure => 'stopped' }}
              it { should contain_service('ntp').with_ensure('stopped') }
            end
          end

          describe 'service_manage' do
            let(:params) {{
              :service_manage => false,
              :service_enable => true,
              :service_ensure => 'running',
              :service_name   => 'ntpd',
            }}

            it 'when set to false' do
              should_not contain_service('ntp').with({
                'enable' => true,
                'ensure' => 'running',
                'name'   => 'ntpd'
              })
            end
          end
        end

        describe 'with parameter iburst_enable' do
          context 'when set to true' do
            let(:params) {{
              :iburst_enable => true,
            }}

            it do
              should contain_file('/etc/ntp.conf').with({
              'content' => /iburst/,
              })
            end
          end

          context 'when set to false' do
            let(:params) {{
              :iburst_enable => false,
            }}

            it do
              should_not contain_file('/etc/ntp.conf').with({
                'content' => /iburst\n/,
              })
            end
          end
        end

        describe 'with tinker parameter changed' do
          describe 'when set to false' do
            context 'when panic or stepout not overriden' do
              let(:params) {{
                :tinker => false,
              }}

              it do
                should_not contain_file('/etc/ntp.conf').with({
                  'content' => /^tinker /,
                })
              end
            end

            context 'when panic overriden' do
              let(:params) {{
                :tinker => false,
                :panic  => 257,
              }}

              it do
                should_not contain_file('/etc/ntp.conf').with({
                  'content' => /^tinker /,
                })
              end
            end

            context 'when stepout overriden' do
              let(:params) {{
                :tinker  => false,
                :stepout => 5,
              }}

              it do
                should_not contain_file('/etc/ntp.conf').with({
                  'content' => /^tinker /,
                })
              end
            end

            context 'when panic and stepout overriden' do
              let(:params) {{
                  :tinker  => false,
                  :panic   => 257,
                  :stepout => 5,
              }}

              it do
                should_not contain_file('/etc/ntp.conf').with({
                  'content' => /^tinker /,
                })
              end
            end
          end
          describe 'when set to true' do
            context 'when only tinker set to true' do
              let(:params) {{
                :tinker => true,
              }}

              it do
                should_not contain_file('/etc/ntp.conf').with({
                  'content' => /^tinker /,
                })
              end
            end

            context 'when panic changed' do
              let(:params) {{
                :tinker => true,
                :panic  => 257,
              }}

              it do
                should contain_file('/etc/ntp.conf').with({
                  'content' => /^tinker panic 257\n/,
                })
              end
            end

            context 'when stepout changed' do
              let(:params) {{
                :tinker  => true,
                :stepout => 5,
              }}

              it do
                should contain_file('/etc/ntp.conf').with({
                  'content' => /^tinker stepout 5\n/,
                })
              end
            end

            context 'when panic and stepout changed' do
              let(:params) {{
                :tinker  => true,
                :panic   => 257,
                :stepout => 5,
              }}

              it do
                should contain_file('/etc/ntp.conf').with({
                  'content' => /^tinker panic 257 stepout 5\n/,
                })
              end
            end
          end
        end

        describe 'with parameters minpoll or maxpoll changed from default' do
          context 'when minpoll changed from default' do
            let(:params) {{
                :minpoll => 3,
            }}

            it do
              should contain_file('/etc/ntp.conf').with({
                'content' => /minpoll 3/,
              })
            end
          end

          context 'when maxpoll changed from default' do
            let(:params) {{
                :maxpoll => 12,
            }}

            it do
              should contain_file('/etc/ntp.conf').with({
                'content' => /maxpoll 12\n/,
              })
            end
          end

          context 'when minpoll and maxpoll changed from default simultaneously' do
            let(:params) {{
                :minpoll => 3,
                :maxpoll => 12,
            }}

            it do
              should contain_file('/etc/ntp.conf').with({
                'content' => /minpoll 3 maxpoll 12\n/,
              })
            end
          end
        end

        describe 'with parameter leapfile' do
          context 'when set to true' do
            let(:params) {{
              :servers => ['a', 'b', 'c', 'd'],
              :leapfile => '/etc/leap-seconds.3629404800',
            }}

            it 'should contain leapfile setting' do
              should contain_file('/etc/ntp.conf').with({
              'content' => /^leapfile \/etc\/leap-seconds\.3629404800\n/,
              })
            end
          end

          context 'when set to false' do
            let(:params) {{
              :servers => ['a', 'b', 'c', 'd'],
            }}

            it 'should not contain a leapfile line' do
              should_not contain_file('/etc/ntp.conf').with({
                'content' => /leapfile /,
              })
            end
          end
        end

        describe 'with parameter logfile' do
          context 'when set to true' do
            let(:params) {{
              :servers => ['a', 'b', 'c', 'd'],
              :logfile => '/var/log/foobar.log',
            }}

            it 'should contain logfile setting' do
              should contain_file('/etc/ntp.conf').with({
              'content' => /^logfile \/var\/log\/foobar\.log\n/,
              })
            end
          end

          context 'when set to false' do
            let(:params) {{
              :servers => ['a', 'b', 'c', 'd'],
            }}

            it 'should not contain a logfile line' do
              should_not contain_file('/etc/ntp.conf').with({
                'content' => /logfile /,
              })
            end
          end
        end

        describe 'with parameter ntpsigndsocket' do
          context 'when set to true' do
            let(:params) {{
                :servers => ['a', 'b', 'c', 'd'],
                :ntpsigndsocket => '/usr/local/samba/var/lib/ntp_signd',
            }}

            it 'should contain ntpsigndsocket setting' do
              should contain_file('/etc/ntp.conf').with({
                'content' => %r(^ntpsigndsocket /usr/local/samba/var/lib/ntp_signd\n),
              })
            end
          end

          context 'when set to false' do
            let(:params) {{
                :servers => ['a', 'b', 'c', 'd'],
            }}

            it 'should not contain a ntpsigndsocket line' do
              should_not contain_file('/etc/ntp.conf').with({
                'content' => /ntpsigndsocket /,
              })
            end
          end
        end

        describe 'with parameter authprov' do
          context 'when set to true' do
            let(:params) {{
                :servers => ['a', 'b', 'c', 'd'],
                :authprov => '/opt/novell/xad/lib64/libw32time.so 131072:4294967295 global',
            }}

            it 'should contain authprov setting' do
              should contain_file('/etc/ntp.conf').with({
                'content' => %r(^authprov /opt/novell/xad/lib64/libw32time.so 131072:4294967295 global\n),
              })
            end
          end

          context 'when set to false' do
            let(:params) {{
                :servers => ['a', 'b', 'c', 'd'],
            }}

            it 'should not contain a authprov line' do
              should_not contain_file('/etc/ntp.conf').with({
                'content' => /authprov /,
              })
            end
          end
        end

        describe 'with parameter tos' do
          context 'when set to true' do
            let(:params) {{
              :tos     => true,
            }}

            it 'should contain tos setting' do
              should contain_file('/etc/ntp.conf').with({
              'content' => /^tos/,
              })
            end
          end

          context 'when set to false' do
            let(:params) {{
              :tos     => false,
            }}

            it 'should not contain tos setting' do
              should_not contain_file('/etc/ntp.conf').with({
                'content' => /^tos/,
              })
            end
          end
        end

        describe 'peers' do
          context 'when empty' do
            let(:params) do
              {
                :peers => []
              }
            end

            it 'should not contain a peer line' do
              should contain_file('/etc/ntp.conf').without_content(/^peer/)
            end
          end

          context 'set' do
            let(:params) do
              {
                :peers => ['foo', 'bar'],
              }
            end

            it 'should contain the peer lines' do
              should contain_file('/etc/ntp.conf').with_content(/peer foo/)
              should contain_file('/etc/ntp.conf').with_content(/peer bar/)
            end
          end
        end
      end
    end

    context 'ntp::config' do
      describe "for operating system Gentoo (Facter < 1.7)" do
        let :facts do
          super().merge({ :operatingsystem => 'Gentoo',
                          :osfamily        => 'Linux' })
        end

        it 'uses the NTP pool servers by default' do
          should contain_file('/etc/ntp.conf').with({
            'content' => /server \d.gentoo.pool.ntp.org/,
          })
        end
      end

      describe "on osfamily Gentoo" do
        let :facts do
          super().merge({ :osfamily        => 'Gentoo',
                          :operatingsystem => 'Gentoo' })
        end

        it 'uses the NTP pool servers by default' do
          should contain_file('/etc/ntp.conf').with({
            'content' => /server \d.gentoo.pool.ntp.org/,
          })
        end
      end

      describe "on osfamily Debian" do
        let :facts do
          super().merge({ :osfamily        => 'debian',
                          :operatingsystem => 'debian' })
        end

        it 'uses the debian ntp servers by default' do
          should contain_file('/etc/ntp.conf').with({
            'content' => /server \d.debian.pool.ntp.org iburst\n/,
          })
        end
      end

      describe "on osfamily RedHat" do
        let :facts do
          super().merge({ :osfamily        => 'RedHat',
                          :operatingsystem => 'RedHat' })
        end

        it 'uses the redhat ntp servers by default' do
          should contain_file('/etc/ntp.conf').with({
            'content' => /server \d.centos.pool.ntp.org/,
          })
        end
      end

      describe "on osfamily Suse" do
        let :facts do
          super().merge({ :osfamily => 'Suse', :operatingsystem => 'SLES',:operatingsystemmajrelease => '11' })
        end

        it 'uses the opensuse ntp servers by default' do
          should contain_file('/etc/ntp.conf').with({
            'content' => /server \d.opensuse.pool.ntp.org/,
            })
        end
      end

      describe "on osfamily FreeBSD" do
        let :facts do
          super().merge({ :osfamily        => 'FreeBSD',
                          :operatingsystem => 'FreeBSD' })
        end

        it 'uses the freebsd ntp servers by default' do
          should contain_file('/etc/ntp.conf').with({
            'content' => /server \d.freebsd.pool.ntp.org iburst maxpoll 9/,
          })
        end
      end

      describe "on osfamily ArchLinux" do
        let :facts do
          super().merge({ :osfamily        => 'ArchLinux',
                          :operatingsystem => 'ArchLinux'})
        end

        it 'uses the ArchLinux NTP servers by default' do
          should contain_file('/etc/ntp.conf').with({
            'content' => /server \d.arch.pool.ntp.org/,
          })
        end
      end

      describe "on osfamily Solaris and kernelrelease 5.10" do
        let :facts do
          super().merge({ :osfamily        => 'Solaris', 
                          :kernelrelease   => '5.10',
                          :operatingsystem => 'Solaris' })
        end

        it 'uses the NTP pool servers by default' do
          should contain_file('/etc/inet/ntp.conf').with({
            'content' => /server \d.pool.ntp.org/,
          })
        end
      end

      describe "on osfamily Solaris and kernelrelease 5.11" do
        let :facts do
          super().merge({ :osfamily        => 'Solaris',
                          :kernelrelease   => '5.11',
                          :operatingsystem => 'Solaris' })
        end

        it 'uses the NTP pool servers by default' do
          should contain_file('/etc/inet/ntp.conf').with({
            'content' => /server \d.pool.ntp.org/,
          })
        end
      end

      describe "for operating system family unsupported" do
        let :facts do
          super().merge({
          :osfamily  => 'unsupported',
        })
        end

        it { expect{ catalogue }.to raise_error(
          /The ntp module is not supported on an unsupported based system./
        )}
      end
    end

    describe 'for virtual machines' do
      let :facts do
        super().merge({ :osfamily        => 'Archlinux',
                        :is_virtual      => 'true',
                        :operatingsystem => 'Archlinux' })
      end

      it 'should not use local clock as a time source' do
        should_not contain_file('/etc/ntp.conf').with({
          'content' => /server.*127.127.1.0.*fudge.*127.127.1.0 stratum 10/,
        })
      end

      it 'allows large clock skews' do
        should contain_file('/etc/ntp.conf').with({
          'content' => /tinker panic 0/,
        })
      end
    end

    describe 'for physical machines' do
      let :facts do
        super().merge({ :osfamily        => 'Archlinux',
                        :is_virtual      => 'false',
                        :operatingsystem => 'Archlinux' })
      end

      it 'disallows large clock skews' do
        should_not contain_file('/etc/ntp.conf').with({
          'content' => /tinker panic 0/,
        })
      end
    end
  end
end
