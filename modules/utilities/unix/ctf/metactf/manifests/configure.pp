class metactf::configure {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $install_dir = '/tmp/metactf'
  $challenge_list = $secgen_params['challenge_list']
  $flags = $secgen_params['flags']
  $groups = $secgen_params['groups']
  $include_chapters = str2bool($secgen_params['include_chapters'][0])
  $include_scaffolding = str2bool($secgen_params['include_scaffolding'][0])

  $raw_account = $secgen_params['account'][0]
  $account = parsejson($raw_account)
  $username = $account['username']

  # TODO : Test me with dynamic challenge directory...
  # if $secgen_params['challenge_directory'][0] != undef {
  #   $challenge_directory = $secgen_params['challenge_directory'][0]
  # } else {
  $storage_dir = "/home/$username/challenges"
  # }

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  # Move the challenges based on account name and challenge name.

  $challenge_pairs = zip($challenge_list, $flags)

  $challenge_pairs.each |$counter, $challenge_pair| {
    $flag = $challenge_pair[1]
    $challenge_path = $challenge_pair[0]

    $split_challenge = split($challenge_path, '/')
    $metactf_challenge_category = $split_challenge[0]

    if $metactf_challenge_category == 'src_angr'{
      $metactf_challenge_type = split($metactf_challenge_category, '_')[1]
      $challenge_name = $split_challenge[1]
      $binary_path = "$install_dir/$metactf_challenge_category/obj/secgen/$metactf_challenge_type/$challenge_name"

      if !$include_chapters {
        $split_challenge_name = split($challenge_name,'_')
        $chapterless_name_arr = $split_challenge_name[2,-1]
        if $chapterless_name_arr.size > 1 {
          $target_challenge_name = join($chapterless_name_arr, '_')
        } else {
          $target_challenge_name = $chapterless_name_arr[0]
        }
      } else {
        $target_challenge_name = $challenge_name
      }

      if $include_scaffolding {
        $challenge_number = split($challenge_name, '_')[0]
        $scaffold_filename = "scaffold$challenge_number.py"

        $scaffold_path = "$install_dir/$metactf_challenge_category/$challenge_name/$scaffold_filename"

        file { "create-$challenge_name-$scaffold_filename":
          path => "$storage_dir/$challenge_name/$scaffold_filename",
          ensure => file,
          source => $scaffold_path,
        }
      }

    } else {
      $challenge_outer_dir = $split_challenge[1]
      $challenge_name = $split_challenge[2]
      $binary_path = "$install_dir/$metactf_challenge_category/$challenge_outer_dir/$challenge_name/obj/secgen/$challenge_name"

      if !$include_chapters {
        $split_challenge_name = split($challenge_name,'_')
        $target_challenge_name = $split_challenge_name[-1]
      } else {
        $target_challenge_name = $challenge_name
      }
    }

    $group = $groups[$counter]

    ::secgen_functions::install_setgid_binary { "metactf_$challenge_name":
      source_module_name => $module_name,
      challenge_name     => $target_challenge_name,
      group              => $group,
      account            => $account,
      flag               => $flag,
      flag_name          => 'flag',
      binary_path        => $binary_path,
      storage_dir        => $storage_dir,
      strings_to_leak    => $secgen_params['strings_to_leak'],
    }

  }

}