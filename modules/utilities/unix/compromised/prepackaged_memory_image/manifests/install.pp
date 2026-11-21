# Ships a pre-captured, atomically-acquired RAM image to the analyst's home
# directory, then rewrites the per-build artefact tokens baked into it (each a
# fixed-length hex string) with this build's random values. Because every
# replacement is the same length as the value it replaces, the patch is done in
# place and no byte moves, so every process structure, socket and string offset
# Volatility reads stays where it was captured.
class prepackaged_memory_image::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  # The analyst account the image is placed under. Accept either a JSON account
  # hash (as the accounts modules emit) or a bare username string; fall back to
  # root so a standalone build still provisions.
  $raw_account = $secgen_parameters['account'] ? {
    undef   => '',
    default => $secgen_parameters['account'][0],
  }
  if $raw_account and $raw_account != '' {
    if $raw_account =~ /^\s*\{/ {
      $username = parsejson($raw_account)['username']
    } else {
      $username = $raw_account
    }
  } else {
    $username = 'root'
  }
  $home = $username ? {
    'root'  => '/root',
    default => "/home/${username}",
  }

  # The per-build token values. These are what the student recovers from the
  # image and submits to Hackerbot; the same datastores feed the compromised
  # server's live artefacts and Hackerbot's expected answers.
  $deleted_proc_name = $secgen_parameters['deleted_proc_name'][0]
  $nc_proc_name      = $secgen_parameters['nc_proc_name'][0]
  $nc_ref_token      = $secgen_parameters['nc_ref_token'][0]
  $env_token         = $secgen_parameters['env_token'][0]
  $bash_token        = $secgen_parameters['bash_token'][0]

  ensure_packages(['xz-utils', 'python3'])

  $stage       = '/opt/prepackaged_memory_image'
  $evidence    = "${home}/evidence"
  $image_name  = 'compromised_server.raw'
  $target      = "${evidence}/${image_name}"

  file { $stage:
    ensure => directory,
    mode   => '0755',
  }

  file { "${stage}/patch_golden.py":
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/prepackaged_memory_image/patch_golden.py',
    require => File[$stage],
  }

  file { "${stage}/golden_tokens.json":
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/prepackaged_memory_image/golden_tokens.json',
    require => File[$stage],
  }

  # The compressed golden image is large (~129 MB), over GitHub's 100 MB
  # per-file limit, so it ships as 50 MiB parts (split -b 50M) reassembled below
  # before decompression -- the same convention SecGen uses for gitlab/spark/druid.
  # The part list follows the split: regenerate it if the image size changes.
  $golden_parts = ['golden.img.xz.partaa', 'golden.img.xz.partab', 'golden.img.xz.partac']
  $golden_parts.each |$part| {
    file { "${stage}/${part}":
      ensure  => file,
      mode    => '0644',
      source  => "puppet:///modules/prepackaged_memory_image/${part}",
      require => File[$stage],
    }
  }

  # mkdir -p the analyst's evidence directory (parents created if the account's
  # home does not yet exist; chown below fixes ownership once it does).
  ::secgen_functions::create_directory { 'pmi_evidence_dir':
    res  => 'pmi_evidence_dir',
    path => $evidence,
  }

  Exec {
    path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
  }

  # Reassemble the split parts into the single compressed image before decompress
  # (cat ...parta* > file -- the glob expands in sorted order, so partaa..partac
  # concatenate correctly).
  exec { 'pmi_reassemble_golden':
    command  => "cat ${stage}/golden.img.xz.parta* > ${stage}/golden.img.xz",
    provider => shell,
    creates  => "${stage}/golden.img.xz",
    timeout  => 0,
    require  => $golden_parts.map |$part| { File["${stage}/${part}"] },
  }

  exec { 'pmi_decompress_golden':
    command  => "xz -dc ${stage}/golden.img.xz > ${target}",
    provider => shell,
    creates  => $target,
    timeout  => 0,
    require  => [Exec['pmi_reassemble_golden'],
                Secgen_functions::Create_directory['pmi_evidence_dir']],
  }

  # Rewrite each baked token to this build's value, in place. Runs exactly once
  # (the baked values exist only before the first patch); guarded by a stamp.
  exec { 'pmi_patch_golden':
    command => "python3 ${stage}/patch_golden.py --image ${target} --tokens ${stage}/golden_tokens.json --set deleted_proc_name=${deleted_proc_name} --set nc_proc_name=${nc_proc_name} --set nc_ref_token=${nc_ref_token} --set env_token=${env_token} --set bash_token=${bash_token} && touch ${evidence}/.patched",
    creates   => "${evidence}/.patched",
    logoutput => true,
    timeout   => 0,
    require   => [Exec['pmi_decompress_golden'],
                  File["${stage}/patch_golden.py"],
                  File["${stage}/golden_tokens.json"]],
  }

  # Hand the evidence directory to the analyst once the account exists.
  exec { 'pmi_chown_evidence':
    command => "chown -R ${username}:${username} ${evidence}",
    onlyif  => "id ${username}",
    require => Exec['pmi_patch_golden'],
  }
}
