require 'spec_helper_acceptance'

case fact('osfamily')
when 'Debian'
  service_name = 'apache2'
  majrelease = fact('operatingsystemmajrelease')
  if ['6', '7', '10.04', '12.04'].include?(majrelease)
    variant = :itk_only
  else
    variant = :prefork
  end
when 'RedHat'
  unless fact('operatingsystemmajrelease') == '5'
    service_name = 'httpd'
    majrelease = fact('operatingsystemmajrelease')
    if ['6'].include?(majrelease)
      variant = :itk_only
    else
      variant = :prefork
    end
  end
when 'FreeBSD'
  service_name = 'apache24'
  majrelease = fact('operatingsystemmajrelease')
  variant = :prefork
end

describe 'apache::mod::itk class', :if => service_name do
  describe 'running puppet code' do
    # Using puppet_apply as a helper
    let(:pp) do
      case variant
        when :prefork
          <<-EOS
            class { 'apache':
              mpm_module => 'prefork',
            }
            class { 'apache::mod::itk': }
          EOS
        when :itk_only
          <<-EOS
            class { 'apache':
              mpm_module => 'itk',
            }
          EOS
        end
    end
    # Run it twice and test for idempotency
    it_behaves_like "a idempotent resource"
  end

  describe service(service_name) do
    it { is_expected.to be_running }
    if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
      pending 'Should be enabled - Bug 760616 on Debian 8'
    else
      it { should be_enabled }
    end
  end
end
