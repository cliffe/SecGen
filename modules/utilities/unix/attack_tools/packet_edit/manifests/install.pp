class packet_edit::install {
    Exec { path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'] }

    ensure_packages(['git', 'make', 'gcc'])

    exec {'clone packet_edit':
        command => 'git clone https://github.com/sgkdev/packet_edit_meme /opt/packet_edit_meme',
        creates => '/opt/packet_edit_meme',
        require => Package['git'],
    } ->
    exec {'make packet_edit':
        command => 'make',
        cwd     => '/opt/packet_edit_meme',
        require => [Package['make'], Package['gcc']],
    } ->
    exec {'packet_edit world readable':
        command => 'chmod -R o+rX /opt/packet_edit_meme',
    }
}