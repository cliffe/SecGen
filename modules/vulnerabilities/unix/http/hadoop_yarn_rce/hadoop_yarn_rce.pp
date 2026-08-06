# begining of puppet code execution

contain hadoop_yarn_rce::install
contain hadoop_yarn_rce::hadoop
Class['hadoop_yarn_rce::install']->
Class['hadoop_yarn_rce::hadoop'] 