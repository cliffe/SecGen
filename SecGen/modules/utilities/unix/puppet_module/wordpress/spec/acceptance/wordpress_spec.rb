require 'spec_helper_acceptance'

describe "setting up a wordpress instance" do
  it 'deploys a wordpress instance' do
    pp = %{
      class { 'apache':
        mpm_module => 'prefork',
      }
      class { 'apache::mod::php': }
      class { 'mysql::server': }
      class { 'mysql::bindings': php_enable => true, }
      host { 'wordpress.localdomain': ip => '127.0.0.1', }

      apache::vhost { 'wordpress.localdomain':
        docroot => '/opt/wordpress',
        port    => '80',
      }

      class { 'wordpress':
        install_dir => '/opt/wordpress/blog',
        require     => Class['mysql::server'],
      }
    }

    expect(apply_manifest(pp, :catch_failures => true).stderr).to eq("")
    expect(apply_manifest(pp, :catch_changes  => true).stderr).to eq("")

    expect(shell("/usr/bin/curl wordpress.localdomain:80/blog/wp-admin/install.php").stdout).to match(/Install WordPress/)
  end

  it 'deploys two wordpress instances' do
    pp = %{
      class { 'apache':
        mpm_module => 'prefork',
      }
      class { 'apache::mod::php': }
      class { 'mysql::server': }
      class { 'mysql::bindings': php_enable => true, }
      host { 'wordpress1.localdomain': ip => '127.0.0.1', }
      host { 'wordpress2.localdomain': ip => '127.0.0.1', }

      apache::vhost { 'wordpress1.localdomain':
        docroot => '/opt/wordpress1',
        port    => '80',
      }
      apache::vhost { 'wordpress2.localdomain':
        docroot => '/opt/wordpress2',
        port    => '80',
      }

      wordpress::instance { '/opt/wordpress1/blog':
        db_name => 'wordpress1',
        db_user => 'wordpress1',
        require => Class['mysql::server'],
      }
      wordpress::instance { '/opt/wordpress2/blog':
        db_name => 'wordpress2',
        db_user => 'wordpress2',
        require => Class['mysql::server'],
      }
    }

    expect(apply_manifest(pp, :catch_failures => true).stderr).to eq("")
    expect(apply_manifest(pp, :catch_changes  => true).stderr).to eq("")

    expect(shell("/usr/bin/curl wordpress1.localdomain:80/blog/wp-admin/install.php").stdout).to match(/Install WordPress/)
    expect(shell("/usr/bin/curl wordpress2.localdomain:80/blog/wp-admin/install.php").stdout).to match(/Install WordPress/)
  end

  it 'deploys a wordpress instance as the httpd user with a secure DB password and a specific location' do
    pp = %{
      class { 'apache':
        mpm_module => 'prefork',
      }
      class { 'apache::mod::php': }
      class { 'mysql::server': }
      class { 'mysql::bindings::php': }

      apache::vhost { 'wordpress.localdomain':
        docroot => '/var/www/wordpress',
        port    => '80',
      }

      class { 'wordpress':
        install_dir => '/var/www/wordpress/blog',
        wp_owner    => $apache::user,
        wp_group    => $apache::group,
        db_name     => 'wordpress',
        db_host     => 'localhost',
        db_user     => 'wordpress',
        db_password => 'hvyH(S%t(\"0\"16',
      }
    }

    pending
  end

  it 'deploys a wordpress instance with a remote DB'
  it 'deploys a wordpress instance with a pre-existing DB'
  it 'deploys a wordpress instance of a specific version'
  it 'deploys a wordpress instance from an internal server'
end
