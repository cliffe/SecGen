class metactf::configure {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $install_dir = '/opt/metactf'
  $challenge_list = $secgen_params['challenge_list']
  $include_scaffolding = str2bool($secgen_params['include_scaffolding'][0])

  $raw_account = $secgen_params['account'][0]
  $account = parsejson($raw_account)
  $username = $account['username']
  $storage_dir = "/home/$username/challenges"

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  # Move the challenges based on account name and challenge name.

  $challenge_list.each |$counter, $raw_challenge| {

    notice("raw_challenge: $raw_challenge")
    $challenge = parsejson($raw_challenge)

    $challenge_name = $challenge['challenge_name']
    $challenge_path = $challenge['challenge_path']
    $group = $challenge['group']
    $flag = $challenge['flag']
    $copy_directory = $challenge['copy_directory']
    $port = $challenge['port']
    $include_c = $challenge['include_c']

    $split_challenge = split($challenge_path, '/')
    $metactf_challenge_category = $split_challenge[0]
    $metactf_challenge_type = split($metactf_challenge_category, '_')[1]

    # Challenge paths:
    # src_angr: /tmp/metactf/src_angr/obj/secgen/angr/00_angr_find
    # src_csp: /tmp/metactf/src_csp/Ch1-2/Ch1_Ltrace/obj/secgen/Ch1_Ltrace
    # src_malware: /tmp/metactf/src_malware/Ch01-08/Ch01StatA_Readelf/obj/secgen/Ch01StatA_Readelf

    if $metactf_challenge_type == 'angr' {
      $binary_path = "$install_dir/$metactf_challenge_category/obj/secgen/angr/$challenge_name"
    } else {
      $binary_path = "$install_dir/$challenge_path/obj/secgen/$challenge_name"
    }

    if $metactf_challenge_category == 'src_angr' and $include_scaffolding {
      $challenge_number = split($challenge_name, '_')[0]
      $scaffold_filename = "scaffold$challenge_number.py"
      $scaffold_path = "$install_dir/$metactf_challenge_category/$challenge_name/$scaffold_filename"

      file { "create-$challenge_name-$scaffold_filename":
        path   => "$storage_dir/$challenge_name/$scaffold_filename",
        ensure => file,
        source => $scaffold_path,
      }
    }

    ::secgen_functions::install_setgid_binary { "metactf_$challenge_name":
      source_module_name => $module_name,
      challenge_name     => $challenge_name,
      group              => $group,
      account            => $account,
      flag               => $flag,
      flag_name          => 'flag',
      binary_path        => $binary_path,
      storage_dir        => $storage_dir,
      share_dir          => $copy_directory,
      port               => $port,
    }

    # This level links against a library built alongside it. A setgid binary ignores LD_LIBRARY_PATH and
    # $ORIGIN, so the library goes on the system path; the angr scaffold works on the copy beside the binary.
    if $challenge_name == '14_angr_shared_library' {
      $shared_library = "lib$challenge_name.so"
      $shared_library_source = "$install_dir/$metactf_challenge_category/obj/secgen/angr/$shared_library"

      file { "/usr/local/lib/$shared_library":
        ensure  => file,
        source  => $shared_library_source,
        mode    => '0755',
        require => Secgen_functions::Install_setgid_binary["metactf_$challenge_name"],
      } ~>
      exec { "ldconfig for $shared_library":
        command     => 'ldconfig',
        refreshonly => true,
      }

      file { "$storage_dir/$challenge_name/$shared_library":
        ensure  => file,
        source  => $shared_library_source,
        mode    => '0644',
        require => Secgen_functions::Install_setgid_binary["metactf_$challenge_name"],
      }
    }

    if $include_c {
      notice("include_c: \"$storage_dir/$challenge_name/program.c\"")
      file { "$storage_dir/$challenge_name/program.c":
        source => "$install_dir/$challenge_path/program.c",
        ensure => file,
        path => "$storage_dir/$challenge_name/program.c",
      }
    }
  }
}