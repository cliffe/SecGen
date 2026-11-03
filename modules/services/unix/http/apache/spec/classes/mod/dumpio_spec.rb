require 'spec_helper'

describe 'apache::mod::dumpio', :type => :class do
  context "on a Debian OS" do
    let :pre_condition do
      'class{"apache":
         default_mods => false,
         mod_dir    => "/tmp/junk",
       }'
    end
    let :facts do
      {
        :lsbdistcodename           => 'squeeze',
        :osfamily                  => 'Debian',
        :operatingsystemrelease    => '6',
        :operatingsystemmajrelease => '6',
        :concat_basedir            => '/dne',
        :operatingsystem           => 'Debian',
        :id                        => 'root',
        :kernel                    => 'Linux',
        :path                      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    context "default configuration fore parameters" do
      it { should compile }
      it { should contain_class('apache::mod::dumpio') }
      it { should contain_file("dumpio.conf").with_path("/tmp/junk/dumpio.conf") }
      it { should contain_file("dumpio.conf").with_content(/^\s*DumpIOInput\s+"Off"$/)}
      it { should contain_file("dumpio.conf").with_content(/^\s*DumpIOOutput\s+"Off"$/)}
    end
    context "with dumpio_input set to On" do
      let :params do
        {
          :dump_io_input => 'On',
        }
      end
      it { should contain_file("dumpio.conf").with_content(/^\s*DumpIOInput\s+"On"$/)}
      it { should contain_file("dumpio.conf").with_content(/^\s*DumpIOOutput\s+"Off"$/)}
    end
    context "with dumpio_ouput set to On" do
      let :params do
        {
          :dump_io_output => 'On',
        }
      end
      it { should contain_file("dumpio.conf").with_content(/^\s*DumpIOInput\s+"Off"$/)}
      it { should contain_file("dumpio.conf").with_content(/^\s*DumpIOOutput\s+"On"$/)}
    end
  end
end
