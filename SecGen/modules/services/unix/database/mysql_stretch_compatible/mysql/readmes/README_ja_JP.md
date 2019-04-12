# mysql

#### 目次

1. [説明 - モジュールの機能とその有益性](#module-description)
2. [セットアップ - mysql導入の基本](#setup)
    * [mysqlの導入](#beginning-with-mysql)
3. [使用方法 - 設定オプションと追加機能](#usage)
    * [サーバオプションのカスタマイズ](#customize-server-options)
    * [データベースを作成します](#create-a-database)
    * [設定のカスタマイズ](#customize-configuration)
    * [既存のサーバに対する操作](#work-with-an-existing-server)
    * [パスワードの指定](#specify-passwords)
    * [CentOSへのPerconaサーバのインストール](#install-percona-server-on-centos)
    * [UbuntuへのMariaDBのインストール](#install-mariadb-on-ubuntu)
    * [プラグインのインストール](#install-plugins)
4. [参考 - モジュールの機能と動作について](REFERENCE.md)
5. [制約 - OS互換性など](#limitations)
6. [開発 - モジュール貢献についてのガイド](#development)

## モジュールの概要

mysqlモジュールは、MySQLサービスをインストール、設定、管理します。

このモジュールは、MySQLのインストールと設定を管理するとともに、データベース、ユーザ、GRANT権限などのMySQLリソースを管理できるようにPuppetの機能を拡張します。

## セットアップ

### mysqlの導入

デフォルトのオプションを使用してサーバをインストールするには、次のコマンドを使用します。

`include '::mysql::server'`.

ルートパスワードや`/etc/my.cnf`の設定値などのオプションをカスタマイズするには、オーバーライドハッシュも渡す必要があります。

```puppet
class { '::mysql::server':
  root_password           => 'strongpassword',
  remove_default_accounts => true,
  override_options        => $override_options
}
```

$override_options用のハッシュ構造体の例については、後述の[**サーバオプションのカスタマイズ**](#サーバオプションのカスタマイズ)を参照してください。

## 使用

サーバに関するすべてのインタラクションは`mysql::server`を使用して行われ、クライアントのインストールには`mysql::client`が、バインディングのインストールには`mysql::bindings`が使用されます。

### サーバオプションのカスタマイズ

サーバオプションを定義するには、`mysql::server`でオーバーライドのハッシュ構造体を作成します。このハッシュは、my.cnfファイルに含まれているハッシュと似ています。

```puppet
$override_options = {
  'section' => {
    'item' => 'thing',
  }
}
```

この形式のオプションを従来の方法で示すと次のようになります。

```
[section]
thing = X
```

ハッシュ内では`thing => true`、`thing => value`、または`thing => ""`の形でエントリを作成できます。または、`thing => ['value', 'value2']`の形で配列を渡したり、`thing => value`を独立した行に個別にリストすることもできます。

値を設定せずに変数をハッシュに含めて渡すことができます。この場合、変数にはMySQLのデフォルトの設定値が使用されます。オプションを`my.cnf`ファイルから除外するには(たとえば`override_options`を使用してデフォルト値に戻す場合など)、`thing => undef`を渡します。

オプションに複数のインスタンスが必要な場合は配列を渡します。たとえば次の例の場合は、

```puppet
$override_options = {
  'mysqld' => {
    'replicate-do-db' => ['base1', 'base2'],
  }
}
```

次のようになります。

```puppet
[mysqld]
replicate-do-db = base1
replicate-do-db = base2
```

バージョンに固有なパラメータを実装するには、[mysqld-5.5]のようにバージョンを指定します。こうすると、1つのconfigで複数の異なるバージョンのMySQLに対応できます。

### データベースを作成します

ユーザおよび割り当てられたいくつかの権限を含むデータベースを作成するには、次のようにします。

```puppet
mysql::db { 'mydb':
  user     => 'myuser',
  password => 'mypass',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE'],
}
```

エクスポートされたリソースを含む別のリソース名を使用するには、次のようにします。

```puppet
 @@mysql::db { "mydb_${fqdn}":
  user     => 'myuser',
  password => 'mypass',
  dbname   => 'mydb',
  host     => ${fqdn},
  grant    => ['SELECT', 'UPDATE'],
  tag      => $domain,
}
```

さらに、これをリモートDBサーバに集めることができます。

```puppet
Mysql::Db <<| tag == $domain |>>
```

データベースの作成時にファイルにsqlパラメータを設定する場合は、新しいデータベースにファイルがインポートされます。

サイズの大きいsqlファイルの場合は、`import_timeout`パラメータの値(デフォルト値300秒)を大きくします。

```puppet
mysql::db { 'mydb':
  user     => 'myuser',
  password => 'mypass',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE'],
  sql      => '/path/to/sqlfile.gz',
  import_cat_cmd => 'zcat',
  import_timeout => 900,
}
```

### 設定のカスタマイズ

MySQLカスタム設定を追加するには、`includedir`にファイルを追加します。こうすると設定値をオーバーライドしたり別の設定値を追加したりすることができ、`mysql::server`で`override_options`を使用しない場合に役立ちます。`includedir`の場所は、デフォルトでは`/etc/mysql/conf.d`に設定されます。

### 既存のサーバに対する操作

既存のMySQLサーバ上にデータベースとユーザのインスタンスを作成するには、`root`のホームディレクトリに`.my.cnf`ファイルが必要です。次の例のように、このファイルでリモートサーバのアドレスと認証情報を指定する必要があります。

```puppet
[client]
user=root
host=localhost
password=secret
```

このモジュールは、`mysqld_version`ファクトから、使用されているサーバのバージョンを認識します。デフォルトでは、`mysqld_version`は`mysqld -V`の出力に設定されています。リモートMySQLサーバに対する操作を行う場合は、`mysqld_version`に対応するカスタムファクトを設定しないと正常に動作しない可能性があります。

リモートサーバに対する操作を行う際には、Puppetマニフェスト内で`mysql::server`クラスを使用*しない*でください。

### パスワードの指定

パスワードは、プレーンテキストとして渡せるだけでなく、次のようにハッシュとして入力することもできます。

```puppet
mysql::db { 'mydb':
  user     => 'myuser',
  password => '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE'],
}
```

必要に応じて、パスワードも空文字列とし、パスワードなしで接続を許可することができます。

### CentOSへのPerconaサーバのインストール

次の例は、CentOSシステムへのPerconaサーバの最小限のインストール方法を示します。この例では、Perconaサーバ、クライアント、バインディング(PerlとPythonのバインディングを含む)がセットアップされます。この方法をカスタマイズして必要に応じバージョンを更新することができます。

この方法は、Puppet 4.4/CentOS 7/Perconaサーバ5.7でテストされています。

注意：** yumレポジトリのインストールはこのパッケージには含まれていません。

```puppet
yumrepo { 'percona':
  descr    => 'CentOS $releasever - Percona',
  baseurl  => 'http://repo.percona.com/centos/$releasever/os/$basearch/',
  gpgkey   => 'http://www.percona.com/downloads/percona-release/RPM-GPG-KEY-percona',
  enabled  => 1,
  gpgcheck => 1,
}

class {'mysql::server':
  package_name     => 'Percona-Server-server-57',
  package_ensure   => '5.7.11-4.1.el7',
  service_name     => 'mysql',
  config_file      => '/etc/my.cnf',
  includedir       => '/etc/my.cnf.d',
  root_password    => 'PutYourOwnPwdHere',
  override_options => {
    mysqld => {
      log-error => '/var/log/mysqld.log',
      pid-file  => '/var/run/mysqld/mysqld.pid',
    },
    mysqld_safe => {
      log-error => '/var/log/mysqld.log',
    },
  }
}

# 注意：Percona-Server-server-57をインストールするとPercona-Server-client-57もインストールされます。
# 次の例は、Percona MySQLクライアントを単独でインストールする方法を示します。
class {'mysql::client':
  package_name   => 'Percona-Server-client-57',
  package_ensure => '5.7.11-4.1.el7',
}

# 通常、以下のパッケージはPercona-Server-server-57とともにインストールされます。
# バインディングもインストールする必要がある場合は、このコードでインストールできます。
class { 'mysql::bindings':
  client_dev_package_name   => 'Percona-Server-shared-57',
  client_dev_package_ensure => '5.7.11-4.1.el7',
  client_dev                => true,
  daemon_dev_package_name   => 'Percona-Server-devel-57',
  daemon_dev_package_ensure => '5.7.11-4.1.el7',
  daemon_dev                => true,
  perl_enable               => true,
  perl_package_name         => 'perl-DBD-MySQL',
  python_enable             => true,
  python_package_name       => 'MySQL-python',
}

# Dependencies definition
Yumrepo['percona']->
Class['mysql::server']

Yumrepo['percona']->
Class['mysql::client']

Yumrepo['percona']->
Class['mysql::bindings']
```

### UbuntuへのMariaDBのインストール

#### オプション：MariaDBの公式のレポジトリのインストール

次の例では、distroレポジトリでなく公式のMariaDBレポジトリの最新の安定版(現在10.1)を使用しています。代わりに、Ubuntuレポジトリのパッケージを使用することもできます。必要に応じた正しいバージョンのレポジトリを使用してください。

**注意：** `sfo1.mirrors.digitalocean.com`は利用可能な多くのミラーの一例であり、公式のミラーであればいずれも使用できます。

```puppet
include apt

apt::source { 'mariadb':
  location => 'http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu',
  release  => $::lsbdistcodename,
  repos    => 'main',
  key      => {
    id     => '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB',
    server => 'hkp://keyserver.ubuntu.com:80',
  },
  include => {
    src   => false,
    deb   => true,
  },
}
```

#### MariaDBサーバのインストール

次の例では、Ubuntu TrustyへのMariaDBサーバのインストール方法を示しています。`my.cnf`のバージョンとパラメータは、必要に応じて調整してください。`my.cnf`のパラメータはすべて`override_options`パラメータを使用して定義できます。

フォルダ`/var/log/mysql`と`/var/run/mysqld`は自動的に作成されますが、他のカスタムフォルダを使用する場合は、それらがコードの必須要件になります。

以下に示す値はすべて、最小限の構成にする場合の例です。

必要なパッケージのバージョンを、`package_ensure`パラメータで指定してください。

```puppet
class {'::mysql::server':
  package_name     => 'mariadb-server',
  package_ensure   => '10.1.14+maria-1~trusty',
  service_name     => 'mysql',
  root_password    => 'AVeryStrongPasswordUShouldEncrypt!',
  override_options => {
    mysqld => {
      'log-error' => '/var/log/mysql/mariadb.log',
      'pid-file'  => '/var/run/mysqld/mysqld.pid',
    },
    mysqld_safe => {
      'log-error' => '/var/log/mysql/mariadb.log',
    },
  }
}

# 依存関係の管理。レポジトリをインストールする場合はこの例の前のステップで示されている部分だけを使用してください。
Apt::Source['mariadb'] ~>
Class['apt::update'] ->
Class['::mysql::server']

```

#### MariaDBクライアントのインストール

次の例は、MariaDBクライアントとすべてのバインディングを一度にインストールする方法を示します。このインストール操作は、サーバのインストール操作とは別に行うことができます。

必要なパッケージのバージョンを、`package_ensure`パラメータで指定してください。

```puppet
class {'::mysql::client':
  package_name    => 'mariadb-client',
  package_ensure  => '10.1.14+maria-1~trusty',
  bindings_enable => true,
}

# Dependency management. Only use that part if you are installing the repository as shown in the Preliminary step of this example.
Apt::Source['mariadb'] ~>
Class['apt::update'] ->
Class['::mysql::client']
```

### CentOSへのMySQL Communityサーバのインストール

MySQLモジュールおよびHieraを使用して、MySQL CommunityサーバーをCentOSにインストールすることができます。この例は以下のバージョンでテスト済みです。

* MySQL Community Server 5.6
* Centos 7.3
* Hieraを使用したPuppet 3.8.7
* puppetlabs-mysqlモジュールv3.9.0

Puppetで：

```puppet
include ::mysql::server

create_resources(yumrepo, hiera('yumrepo', {}))

Yumrepo['repo.mysql.com'] -> Anchor['mysql::server::start']
Yumrepo['repo.mysql.com'] -> Package['mysql_client']

create_resources(mysql::db, hiera('mysql::server::db', {}))
```

Hieraで：

```yaml
---

# Centos 7.3
yumrepo:
  'repo.mysql.com':
    baseurl: "http://repo.mysql.com/yum/mysql-5.6-community/el/%{::operatingsystemmajrelease}/$basearch/"
    descr: 'repo.mysql.com'
    enabled: 1
    gpgcheck: true
    gpgkey: 'http://repo.mysql.com/RPM-GPG-KEY-mysql'

mysql::client::package_name: "mysql-community-client" # 適切なMySQL導入のために必要
mysql::server::package_name: "mysql-community-server" # 適切なMySQL導入のために必要
mysql::server::package_ensure: 'installed' # ここではバージョンを指定しないでください。残念ながら、パッケージがインストールされているエラーでyumは失敗しました。
mysql::server::root_password: "change_me_i_am_insecure"
mysql::server::manage_config_file: true
mysql::server::service_name: 'mysqld' # Puppetモジュールに必要
mysql::server::override_options:
  'mysqld':
    'bind-address': '127.0.0.1'
    'log-error': '/var/log/mysqld.log' # 適切なMySQL導入のために必要
  'mysqld_safe':
    'log-error': '/var/log/mysqld.log'  # 適切なMySQL導入のために必要

# データベース+アクセスできるアカウント、暗号化されていないパスワードを作成
mysql::server::db:
  "dev":
    user: "dev"
    password: "devpass"
    host: "127.0.0.1"
    grant:
      - "ALL"

```

### プラグインのインストール

プラグインはユーザ定義のタイプ`mysql_plugin` を使用してインストールできます。`examples/mysql_plugin.pp`で、具体的な例を参照してください。

```puppet
class { 'mysql::server':
  root_password => 'password'
}

mysql_plugin { 'auth_pam':
  ensure => present,
  soname => 'auth_pam.so',
}

```

### タスク

MySQLモジュールにはサンプルタスクがあり、ユーザはデータベースに対して任意のSQLを実行できます。[Puppet Enterpriseマニュアル](https://puppet.com/docs/pe/2017.3/orchestrator/running_tasks.html)または[Boltマニュアル](https://puppet.com/docs/bolt/latest/bolt.html)で、タスクを実行する方法に関する情報を参照してください。

## 制約

サポートされているオペレーティングシステムの一覧については、[metadata.json](https://github.com/puppetlabs/puppetlabs-tomcat/blob/master/metadata.json)を参照してください。

**注意：** mysqlbackup.shは、MySQL 5.7以降では動作せず、サポートされていません。

## 開発

Puppet Forge上のPuppetモジュールはオープンプロジェクトであり、その価値を維持するにはコミュニティからの貢献が欠かせません。Puppetが提供する膨大な数のプラットフォームや、無数のハードウェア、ソフトウェア、デプロイ設定に弊社がアクセスすることは不可能です。

弊社は、できるだけ変更に貢献しやすくして、弊社のモジュールがユーザの環境で機能する状態を維持したいと考えています。弊社では、状況を把握できるよう、貢献者に従っていただくべきいくつかのガイドラインを設けています。

弊社の詳細な[モジュール貢献についてのガイドライン](https://docs.puppetlabs.com/forge/contributing.html)をご確認ください。

### 作成者

このモジュールは、David Schmittが作成したものをベースにして、以下の作成者による貢献内容が加えられています(Puppet Labsを除く)。

* Larry Ludwig
* Christian G. Warden
* Daniel Black
* Justin Ellison
* Lowe Schmidt
* Matthias Pigulla
* William Van Hevelingen
* Michael Arnold
* Chris Weyl
* Daniël van Eeden
* Jan-Otto Kröpke
* Timothy Sven Nelson
