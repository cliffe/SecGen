class snort::config{

  file { '/etc/snort/snort.debian.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0777',
    content  => template('snort/snort.debian.conf.erb')
  }

  # enable the alerts file output
  file_line { 'Append a line to /etc/snort/snort.conf':
    path => '/etc/snort/snort.conf',
    line => 'output alert_fast',
  }

  # Supplementary modern rules (shellshock, Drupalgeddon2, id-check) that the ~2010 Debian
  # snort-rules-default package lacks, taken from the current Snort community ruleset. Added
  # *alongside* the stock rules (not replacing them), so labs that reference stock rule files
  # keep working. The full community ruleset is bundled too (community.rules) for later widening.
  file { '/etc/snort/rules/secgen-updated.rules':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/snort/secgen-updated.rules',
  }

  file { '/etc/snort/rules/community.rules':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/snort/community.rules',
  }

  # Load the supplement. $RULE_PATH is defined near the top of the stock snort.conf, so an
  # include appended at the end resolves it. community.rules itself is NOT included by default
  # (its older SIDs would collide with the stock set and it is untested on this Snort); switch
  # it on deliberately after a 'snort -T' once SID de-duplication is handled.
  file_line { 'include secgen-updated.rules':
    path    => '/etc/snort/snort.conf',
    line    => 'include $RULE_PATH/secgen-updated.rules',
    require => File['/etc/snort/rules/secgen-updated.rules'],
  }

}
