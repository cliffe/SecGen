# apache spark rce init
# https://archive.apache.org/dist/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz
# https://spark.apache.org/docs/3.1.2/
# https://packetstormsecurity.com/files/168309/Apache-Spark-Unauthenticated-Command-Injection.html
# https://github.com/rapid7/metasploit-framework/blob/master/modules/exploits/linux/http/apache_spark_rce_cve_2022_33891.rb
contain apache_spark_rce::install
contain apache_spark_rce::configure
contain apache_spark_rce::service
Class['apache_spark_rce::install']
-> Class['apache_spark_rce::configure']
-> Class['apache_spark_rce::service']
