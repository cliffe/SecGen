
require 'spec_helper'

describe 'apache::mod::security', :type => :class do
  it_behaves_like "a mod class, without including apache"
  context "on RedHat based systems" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystem        => 'CentOS',
        :operatingsystemrelease => '7',
        :kernel                 => 'Linux',
        :id                     => 'root',
        :concat_basedir         => '/',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { should contain_apache__mod('security').with(
      :id => 'security2_module',
      :lib => 'mod_security2.so'
    ) }
    it { should contain_apache__mod('unique_id_module').with(
      :id => 'unique_id_module',
      :lib => 'mod_unique_id.so'
    ) }
    it { should contain_package('mod_security_crs') }
    it { should contain_file('security.conf').with(
      :path => '/etc/httpd/conf.modules.d/security.conf'
    ) }
    it { should contain_file('security.conf')
      .with_content(%r{^\s+SecAuditLogRelevantStatus "\^\(\?:5\|4\(\?!04\)\)"$})
      .with_content(%r{^\s+SecAuditLogParts ABIJDEFHZ$})
      .with_content(%r{^\s+SecDebugLog /var/log/httpd/modsec_debug.log$})
      .with_content(%r{^\s+SecAuditLog /var/log/httpd/modsec_audit.log$})
    }
    it { should contain_file('/etc/httpd/modsecurity.d').with(
      :ensure => 'directory',
      :path   => '/etc/httpd/modsecurity.d',
      :owner  => 'root',
      :group  => 'root',
      :mode   => '0755',
    ) }
    it { should contain_file('/etc/httpd/modsecurity.d/activated_rules').with(
      :ensure => 'directory',
      :path => '/etc/httpd/modsecurity.d/activated_rules',
      :owner => 'apache',
      :group => 'apache'
    ) }
    it { should contain_file('/etc/httpd/modsecurity.d/security_crs.conf').with(
      :path => '/etc/httpd/modsecurity.d/security_crs.conf'
    ) }
    it { should contain_apache__security__rule_link('base_rules/modsecurity_35_bad_robots.data') }
    it { should contain_file('modsecurity_35_bad_robots.data').with(
      :path   => '/etc/httpd/modsecurity.d/activated_rules/modsecurity_35_bad_robots.data',
      :target => '/usr/lib/modsecurity.d/base_rules/modsecurity_35_bad_robots.data',
    ) }

    describe 'with parameters' do
      let :params do
        {
          :activated_rules           => [
            '/tmp/foo/bar.conf',
          ],
          :audit_log_relevant_status => "^(?:5|4(?!01|04))",
          :audit_log_parts           => "ABCDZ",
          :secdefaultaction          => "deny,status:406,nolog,auditlog",
        }
      end
      it { should contain_file('security.conf').with_content %r{^\s+SecAuditLogRelevantStatus "\^\(\?:5\|4\(\?!01\|04\)\)"$} }
      it { should contain_file('security.conf').with_content %r{^\s+SecAuditLogParts ABCDZ$} }
      it { should contain_file('/etc/httpd/modsecurity.d/security_crs.conf').with_content %r{^\s*SecDefaultAction "phase:2,deny,status:406,nolog,auditlog"$} }
      it { should contain_file('bar.conf').with(
        :path   => '/etc/httpd/modsecurity.d/activated_rules/bar.conf',
        :target => '/tmp/foo/bar.conf',
      ) }
    end
  end

  context "on Debian based systems" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/',
        :lsbdistcodename        => 'squeeze',
        :id                     => 'root',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :kernel                 => 'Linux',
        :is_pe                  => false,
      }
    end
    it { should contain_apache__mod('security').with(
      :id => 'security2_module',
      :lib => 'mod_security2.so'
    ) }
    it { should contain_apache__mod('unique_id_module').with(
      :id => 'unique_id_module',
      :lib => 'mod_unique_id.so'
    ) }
    it { should contain_package('modsecurity-crs') }
    it { should contain_file('security.conf').with(
      :path => '/etc/apache2/mods-available/security.conf'
    ) }
    it { should contain_file('security.conf')
      .with_content(%r{^\s+SecAuditLogRelevantStatus "\^\(\?:5\|4\(\?!04\)\)"$})
      .with_content(%r{^\s+SecAuditLogParts ABIJDEFHZ$})
      .with_content(%r{^\s+SecDebugLog /var/log/apache2/modsec_debug.log$})
      .with_content(%r{^\s+SecAuditLog /var/log/apache2/modsec_audit.log$})
    }
    it { should contain_file('/etc/modsecurity').with(
      :ensure => 'directory',
      :path   => '/etc/modsecurity',
      :owner  => 'root',
      :group  => 'root',
      :mode   => '0755',
    ) }
    it { should contain_file('/etc/modsecurity/activated_rules').with(
      :ensure => 'directory',
      :path => '/etc/modsecurity/activated_rules',
      :owner => 'www-data',
      :group => 'www-data'
    ) }
    it { should contain_file('/etc/modsecurity/security_crs.conf').with(
      :path => '/etc/modsecurity/security_crs.conf'
    ) }
    it { should contain_apache__security__rule_link('base_rules/modsecurity_35_bad_robots.data') }
    it { should contain_file('modsecurity_35_bad_robots.data').with(
      :path   => '/etc/modsecurity/activated_rules/modsecurity_35_bad_robots.data',
      :target => '/usr/share/modsecurity-crs/base_rules/modsecurity_35_bad_robots.data',
    ) }

    describe 'with parameters' do
      let :params do
        {
          :activated_rules           => [
            '/tmp/foo/bar.conf',
          ],
          :audit_log_relevant_status => "^(?:5|4(?!01|04))",
          :audit_log_parts           => "ABCDZ",
          :secdefaultaction          => "deny,status:406,nolog,auditlog",
        }
      end
      it { should contain_file('security.conf').with_content %r{^\s+SecAuditLogRelevantStatus "\^\(\?:5\|4\(\?!01\|04\)\)"$} }
      it { should contain_file('security.conf').with_content %r{^\s+SecAuditLogParts ABCDZ$} }
      it { should contain_file('/etc/modsecurity/security_crs.conf').with_content %r{^\s*SecDefaultAction "phase:2,deny,status:406,nolog,auditlog"$} }
      it { should contain_file('bar.conf').with(
        :path   => '/etc/modsecurity/activated_rules/bar.conf',
        :target => '/tmp/foo/bar.conf',
      ) }
    end
  end

end
