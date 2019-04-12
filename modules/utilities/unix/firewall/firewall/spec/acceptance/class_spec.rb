require 'spec_helper_acceptance'

describe "firewall class" do
  it 'should run successfully' do
    pp = "class { 'firewall': }"

    # Run it twice and test for idempotency
    apply_manifest(pp, :catch_failures => true)
    if do_catch_changes
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  it 'ensure => stopped:' do
    pp = "class { 'firewall': ensure => stopped }"

    # Run it twice and test for idempotency
    apply_manifest(pp, :catch_failures => true)
    if do_catch_changes
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  it 'ensure => running:' do
    pp = "class { 'firewall': ensure => running }"

    # Run it twice and test for idempotency
    apply_manifest(pp, :catch_failures => true)
    if do_catch_changes
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end
end
