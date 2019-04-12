define secgen_functions::create_directory($res='create-dir', $path){
  exec  { "secgen_create_directory_$res":
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => "mkdir -p $path"
  }
}
