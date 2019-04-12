require 'spec_helper'

describe 'python::pyvenv', :type => :define do
  let (:title) { '/opt/env' }
  let (:facts) do
    {
      :lsbdistcodename => 'jessie',
      :osfamily => 'Debian',
    }
  end

  it {
    is_expected.to contain_file( '/opt/env')
    is_expected.to contain_exec( "python_virtualenv_/opt/env").with_command("pyvenv --clear  /opt/env")
  }

  describe 'when ensure' do
    context "is absent" do
      let (:params) {{
        :ensure => 'absent'
      }}
      it {
        is_expected.to contain_file( '/opt/env').with_ensure('absent').with_purge( true)
      }
    end
  end
end
