# Use a variable OR with hiera_hash():
$groups_hash = {
  'admin'     => { gid => '3000' },
  'sudo'      => { gid => '3001' },
  'sudonopw'  => { gid => '3002' },
  'developer' => { gid => '3003' },
  'ops'       => { gid => '3004' },
}
create_resources('accounts::group', $groups_hash)

$users_hash = {
  'jeff' => {
    'shell'    => '/bin/zsh',
    'comment'  => 'Jeff McCune',
    'groups'   => [ admin, sudonopw, ],
    'uid'      => '1112',
    'gid'      => '1112',
    'locked'   => true,
    'sshkeys'  => [
      'ssh-rsa AAAA...',
      'ssh-dss AAAA...',
    ],
    'password' => '!!',
  },
  'dan' => {
    'comment'  => 'Dan Bode',
    'uid'      => '1109',
    'gid'      => '1109',
  },
}
create_resources('accounts::user', $users_hash)
