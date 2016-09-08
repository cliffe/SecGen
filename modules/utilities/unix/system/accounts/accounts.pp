$username = 'user'
# Password = 'password'
$password = '$6$$bLTg4cpho8PIUrjfsE7qlU08Qx2UEfw..xOc6I1wpGVtyVYToGrr7BzRdAAnEr5lYFr1Z9WcCf1xNZ1HG9qFW1'

accounts::user { $username:
  uid      => '4001',
  gid      => '4001',
  shell    => '/bin/bash',
  name => $username,
  password => $password,

  # sshkeys  => "ssh-rsa AAAA...",
  # locked   => false,
}