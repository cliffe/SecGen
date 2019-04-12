require 'spec_helper_acceptance'

describe 'python class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'python' :
        version    => 'system',
        pip        => 'present',
        virtualenv => 'present',
      }
      ->
      python::virtualenv { 'venv' :
        ensure     => 'present',
        systempkgs => false,
        venv_dir   => '/opt/venv',
        owner      => 'root',
        group      => 'root',
      }
      ->
      python::pip { 'rpyc' :
        ensure     => '3.2.3',
        virtualenv => '/opt/venv',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end
  end
end
