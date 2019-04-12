# Only testing on RedHat because the outcome is the same on Debian.
require 'spec_helper'
describe 'ruby::config', :type => :class do
  describe 'when called with no parameters' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    it {
      should contain_file('ruby_environment').with({
        'ensure' => 'absent',
      })
    }
  end

  describe 'when called setting gc_malloc_limit parameter' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { { :gc_malloc_limit => '10000' } }
    it {
      should contain_file('ruby_environment').with({
        'ensure'  => 'file',
        'path'    => '/etc/profile.d/ruby.sh'
      })
    }
    it {
      should contain_file('ruby_environment').with_content(/^export RUBY_GC_MALLOC_LIMIT=10000$/)
    }
  end

  describe 'when called setting heap_free_min parameter' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { { :heap_free_min => '10000' } }
    it {
      should contain_file('ruby_environment').with({
        'ensure'  => 'file',
        'path'    => '/etc/profile.d/ruby.sh'
      })
    }
    it {
      should contain_file('ruby_environment').with_content(/^export RUBY_HEAP_FREE_MIN=10000$/)
    }
  end

  describe 'when called setting heap_slots_growth_factor parameter' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { { :heap_slots_growth_factor => '10000' } }
    it {
      should contain_file('ruby_environment').with({
        'ensure'  => 'file',
        'path'    => '/etc/profile.d/ruby.sh'
      })
    }
    it {
      should contain_file('ruby_environment').with_content(/^export RUBY_HEAP_SLOTS_GROWTH_FACTOR=10000$/)
    }
  end

  describe 'when called setting heap_min_slots parameter' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { { :heap_min_slots => '10000' } }
    it {
      should contain_file('ruby_environment').with({
        'ensure'  => 'file',
        'path'    => '/etc/profile.d/ruby.sh'
      })
    }
    it {
      should contain_file('ruby_environment').with_content(/^export RUBY_HEAP_MIN_SLOTS=10000$/)
    }
  end

  describe 'when called setting heap_slots_increment parameter' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { { :heap_slots_increment => '10000' } }
    it {
      should contain_file('ruby_environment').with({
        'ensure'  => 'file',
        'path'    => '/etc/profile.d/ruby.sh'
      })
    }
    it {
      should contain_file('ruby_environment').with_content(/^export RUBY_HEAP_SLOTS_INCREMENT=10000$/)
    }
  end

end