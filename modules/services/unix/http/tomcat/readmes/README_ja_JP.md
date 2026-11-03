# tomcat

#### 目次

1. [概要](#概要)
2. [モジュールの説明 - モジュールの機能と役立つ理由](#モジュールの説明)
3. [セットアップ - tomcat導入の基本](#セットアップ)
    * [セットアップ要件](#要件)
    * [tomcatを開始する](#tomcatを開始する)
4. [使用方法 - 設定オプションとその他の機能](#使用方法)
    * [複数のバージョン、複数インスタンスのtomcatを実行したい](#複数のバージョン、複数インスタンスのtomcatを実行したい)
    * [SSLを設定し、使用するプロトコルと暗号を指定したい](#SSLを設定し、使用するプロトコルと暗号を指定したい)
    * [WARファイルをデプロイしたい](#warファイルをデプロイしたい)
    * [構成の一部を削除したい](#構成の一部を削除したい)
    * [既存のConnectorまたはRealmを管理したい](#既存のconnectorまたはrealmを管理したい)
5. [リファレンス - モジュールの内部で何がどのように行われているかのぞいてみよう](#リファレンス)
    * [クラス](#クラス)
    * [定義タイプ](#定義タイプ)
    * [パラメータ](#パラメータ)
        * [tomcat](#tomcat-1)
        * [tomcat::config::properties::property](#tomcatconfigpropertiesproperty)
        * [tomcat::config::server](#tomcatconfigserver)
        * [tomcat::config::server::connector](#tomcatconfigserverconnector)
        * [tomcat::config::server::context](#tomcatconfigservercontext)
        * [tomcat::config::server::engine](#tomcatconfigserverengine)
        * [tomcat::config::server::globalnamingresource](#tomcatconfigserverglobalnamingresource)
        * [tomcat::config::server::host](#tomcatconfigserverhost)
        * [tomcat::config::server::listener](#tomcatconfigserverlistener)
        * [tomcat::config::server::realm](#tomcatconfigserverrealm)
        * [tomcat::config::server::service](#tomcatconfigserverservice)
        * [tomcat::config::server::tomcat_users](#tomcatconfigservertomcat_users)
        * [tomcat::config::server::valve](#tomcatconfigservervalve)
        * [tomcat::config::context](#tomcatconfigcontext)
        * [tomcat::config::context::environment](#tomcatconfigcontextenvironment)
        * [tomcat::config::context::manager](#tomcatconfigcontextmanager)
        * [tomcat::config::context::resource](#tomcatconfigcontextresource)
        * [tomcat::config::context::resourcelink](#tomcatconfigcontextresourcelink)
        * [tomcat::config::context::valve](#tomcatconfigcontextvalve)
        * [tomcat::install](#tomcatinstall)
        * [tomcat::instance](#tomcatinstance)
        * [tomcat::service](#tomcatservice)
        * [tomcat::setenv::entry](#tomcatsetenventry)
        * [tomcat::war](#tomcatwar)
6. [制限事項 - OS互換性など](#制限事項)
7. [開発 -モジュールに貢献するためのガイド](#開発)

## 概要

tomcatモジュールを利用すると、Puppetを使用してTomcat Webサービスをインストール、デプロイ、構成できます。

## モジュールの説明

TomcatはJava Webサービスを提供します。tomcatモジュールを使用すると、Puppetを使用してTomcatをインストールし、その構成ファイルを管理し、Webアプリをデプロイできます。複数のバージョンにまたがる複数のTomcatインスタンスをサポートしています。

## セットアップ

### 要件

tomcatモジュールには、[puppetlabs-stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)バージョン4.0以上が必要です。Puppet Enterpriseでは、モジュールをインストールする前にこの要件を満たす必要があります。stdlibをアップデートするには、以下を実行します。

```bash
puppet module upgrade puppetlabs-stdlib
```
> 注: [バージョンリスト](http://tomcat.apache.org/whichversion.html)でインストールするバージョンを照合してください。

## 使用方法

### 複数のバージョン、複数インスタンスのtomcatを実行したい

```puppet
class { 'java': }

tomcat::install { '/opt/tomcat9':
  source_url => 'https://www.apache.org/dist/tomcat/tomcat-9/v9.0.x/bin/apache-tomcat-9.0.x.tar.gz'
}
tomcat::instance { 'tomcat9-first':
  catalina_home => '/opt/tomcat9',
  catalina_base => '/opt/tomcat9/first',
}
tomcat::instance { 'tomcat9-second':
  catalina_home => '/opt/tomcat9',
  catalina_base => '/opt/tomcat9/second',
}
# 2つ目のインスタンスのサーバおよびHTTPコネクタのデフォルトポートを変更
tomcat::config::server { 'tomcat9-second':
  catalina_base => '/opt/tomcat9/second',
  port          => '8006',
}
tomcat::config::server::connector { 'tomcat9-second-http':
  catalina_base         => '/opt/tomcat9/second',
  port                  => '8081',
  protocol              => 'HTTP/1.1',
  additional_attributes => {
    'redirectPort' => '8443'
  },
}


> 注: [バージョンリスト](http://tomcat.apache.org/whichversion.html)でインストールするバージョンを照合してください。

### SSLを設定し、使用するプロトコルと暗号を指定したい

```puppet
  file { $keystore_path: 
    ensure => present,
    source => $keystore_source,
    owner => $keystore_user,
    mode => '0400',
    checksum => 'md5',
    checksum_value => $keystore_checksum,
  } ->

  tomcat::config::server::connector { "${tomcat_instance}-https":
    catalina_base         => $catalina_base,
    port                  => $https_port,
    protocol              => $http_version,
    purge_connectors      => true,
    additional_attributes => {
      'SSLEnabled'          => bool2str($https_enabled),
      'maxThreads'          => $https_connector_max_threads,
      'scheme'              => $https_connector_scheme,
      'secure'              => bool2str($https_connector_secure),
      'clientAuth'          => bool2str($https_connector_client_auth),
      'sslProtocol'         => $https_connector_ssl_protocol,
      'sslEnabledProtocols' => join($https_connector_ssl_protocols_enabled, ","),
      'ciphers'             => join($ciphers_enabled, ","),
      
      'keystorePass'        => $keystore_pass.unwrap,
      'keystoreFile'        => $keystore_path,
    },
  }
```

> [SSL/TLS Configuration HOW-TO](https://tomcat.apache.org/tomcat-8.5-doc/ssl-howto.html)も参照してください

### WARファイルをデプロイしたい

既存のインストールファイルに次のコードを追加し、warソースの場所を指定します。
```puppet
tomcat::war { 'sample.war':
  catalina_base => '/opt/tomcat9/first',
  war_source    => '/opt/tomcat9/webapps/docs/appdev/sample/sample.war',
}
```

WARファイル名は`.war`で終わる必要があります。

`war_source`はローカルパス、または`puppet:///`、`http://`、`ftp://`のURLを指定できます。

### 構成の一部を削除したい

異なる構成定義を追加することで、ensureパラメータ(名前は定義タイプにより異なる)を受け渡せます。

たとえばコネクタを削除するには、次の構成でコネクタが存在しないものとして処理します。

```puppet
tomcat::config::server::connector { 'tomcat9-jsvc':
  connector_ensure => 'absent',
  catalina_base    => '/opt/tomcat9/first',
  port             => '8080',
  protocol         => 'HTTP/1.1',
}
```

### 既存のConnectorまたはRealmを管理したい

`tomcat::config::server::realm`または`tomcat::config::server::connector`を使用してRealm要素またはHTTP Connector要素を記述し、`purge_realms`または`purge_connectors`を`true`に設定します。

```puppet
tomcat::config::server::realm { 'org.apache.catalina.realm.LockOutRealm':
  realm_ensure => 'present',
  purge_realms => true,
}
```

既存のConnectorまたはRealmはすべてPuppetにより削除され、指定したもののみが残ります。

## リファレンス

### クラス

#### パブリッククラス

* `tomcat`: メインのクラスです。Tomcatをインストールおよび構成するためのデフォルト設定の一部を管理します。

#### プライベートクラス

* `tomcat::params`: Tomcatパラメータを管理します。

### 定義タイプ

#### パブリック定義タイプ

* `tomcat::config::properties::property`: catalina.propertiesファイルにプロパティを追加します。
* `tomcat::config::server`: `$CATALINA_BASE/conf/server.xml`の[Server要素](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html)の属性を構成します。
* `tomcat::config::server::connector`: `$CATALINA_BASE/conf/server.xml`の[Connector要素](http://tomcat.apache.org/tomcat-8.0-doc/connectors.html)を構成します。
* `tomcat::config::server::context`: `$CATALINA_BASE/conf/server.xml`の[Context要素](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html)を構成します。
* `tomcat::config::server::engine`: `$CATALINA_BASE/conf/server.xml`の[Engine要素](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Introduction)を構成します。
* `tomcat::config::server::globalnamingresource`: [Global Resource要素](http://tomcat.apache.org/tomcat-8.0-doc/config/globalresources.html)を構成します。
* `tomcat::config::server::host`: `$CATALINA_BASE/conf/server.xml`の[Host要素](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html)を構成します。
* `tomcat::config::server::listener`: `$CATALINA_BASE/conf/server.xml`の[Listener要素](http://tomcat.apache.org/tomcat-8.0-doc/config/listeners.html)を構成します。
* `tomcat::config::server::realm`: `$CATALINA_BASE/conf/server.xml`の[Realm要素](http://tomcat.apache.org/tomcat-8.0-doc/config/realm.html)を構成します。
* `tomcat::config::server::service`: `$CATALINA_BASE/conf/server.xml`の`Server`要素にネストされた[Service要素](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html)要素を構成します。
* `tomcat::config::server::tomcat_users`: `$CATALINA_BASE/conf/tomcat-users.xml`または指定した他のファイルの[UserDatabaseRealm] (http://tomcat.apache.org/tomcat-8.0-doc/realm-howto.html#UserDatabaseRealm)または[MemoryRealm] (http://tomcat.apache.org/tomcat-8.0-doc/realm-howto.html#MemoryRealm)のユーザおよびロール要素を構成します。
* `tomcat::config::server::valve`: `$CATALINA_BASE/conf/server.xml`の[Valve](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html)要素を構成します。
* `tomcat::config::context`: `$CATALINA_BASE/conf/context.xml`の[Context](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html)要素を構成します。
* `tomcat::config::context::manager`: `$CATALINA_BASE/conf/context.xml`の[Manager](https://tomcat.apache.org/tomcat-8.0-doc/config/manager.html)要素を構成します。
* `tomcat::config::context::environment`: `$CATALINA_BASE/conf/context.xml`の[Environment](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Environment_Entries)要素を構成します。
* `tomcat::config::context::resource`: `$CATALINA_BASE/conf/context.xml`の[Resource](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Resource_Definitions)要素を構成します。
* `tomcat::config::context::resourcelink`: `$CATALINA_BASE/conf/context.xml`の[ResourceLink](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Resource_Links)要素を構成します。
* `tomcat::config::context::valve`: `$CATALINA_BASE/conf/context.xml`の[Valve](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html)要素を構成します。
* `tomcat::install`: Tomcatインスタンスをインストールします。
* `tomcat::instance`: Tomcatインスタンスを構成します。
* `tomcat::service`: Tomcatサービス管理を提供します。
* `tomcat::setenv::entry`: Tomcat設定ファイル(`setenv.sh`または`/etc/sysconfig/tomcat`など)にエントリを追加します。
* `tomcat::war`:  WARファイルのデプロイを管理します。

#### プライベート定義タイプ

* `tomcat::install::package`: パッケージからTomcatをインストールします。
* `tomcat::install::source`: ソースからTomcatをインストールします。
* `tomcat::instance::copy_from_home`: インストールファイルから必要なファイルをインスタンスにコピーします。
* `tomcat::instance::dependencies`: インスタンスのpuppet依存関係チェーンを宣言します。
* `tomcat::config::properties`: インスタンスのcatalina.propertiesを作成します。

### パラメータ

特に指定のない限り、すべてのパラメータの指定は任意です。

#### tomcat
ベースクラスは、`catalina_home`のデフォルトのように、他の定義タイプ(`tomcat::install`や`tomcat::instance`など)によって使用されるデフォルト値を設定します。

##### `catalina_home`

Tomcatのインストール先のデフォルトルートディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '/opt/apache-tomcat'。

##### `group`

Tomcatを実行するデフォルトグループを指定します。

有効なオプション: 有効なグループ名を含む文字列。

デフォルト値: 'tomcat'。

##### `manage_group`

指定されたグループが存在しない場合、定義タイプがデフォルトでそのグループを作成するかどうかを指定します。Puppetのネイティブ[`group`リソースタイプ](https://docs.puppetlabs.com/references/latest/type.html#group)をデフォルトのパラメータとともに使用します。

有効なオプション: `true`と`false`。

デフォルト値: `true`。

##### `manage_user`

指定されたユーザが存在しない場合、定義タイプがデフォルトでそのユーザを作成するかどうかを指定します。Puppetのネイティブ[`user`リソースタイプ](https://docs.puppetlabs.com/references/latest/type.html#user)をデフォルトのパラメータとともに使用します。

有効なオプション: `true`と`false`。

デフォルト値: `true`。

##### `manage_base`

すべての`tomcat::install`インスタンスに対して、`manage_base`のデフォルト値を指定します。

デフォルト値: `true`。

##### `manage_home`

すべての`tomcat::instance`インスタンスに対して、`manage_home`のデフォルト値を指定します。

デフォルト値: `true`。

##### `manage_properties`

すべての`tomcat::instance`インスタンスに対して、`manage_properties`のデフォルト値を指定します。

デフォルト値: `true`。

##### `purge_connectors`

定義されたプロトコルと一致するが、異なるポートを持つ未管理のConnector要素をデフォルトで構成ファイルからパージするかどうかを指定します。

有効なオプション: `true`と`false`。

デフォルト値: `false`。

##### `purge_realms`

未管理のRealm要素をデフォルトで構成ファイルからパージするかどうかを指定します。

有効なオプション: `true`と`false`。

デフォルト値: `false`。1つのサーバ構成に2つのRealmが定義されている場合、1つ目のRealmのみに`purge_realms`を使用し、Realm間の順序が必ず守られるようにします。

##### `user`

Tomcatを実行するデフォルトユーザを指定します。

有効なオプション: 有効なユーザ名を含む文字列。

デフォルト値: 'tomcat'。

#### tomcat::config::properties::property

特定のcatalinaベースのcatalina.propertiesファイルに追加エントリを指定します。

##### `property`

プロパティの名前です。

デフォルト値: `$name`。

##### `catalina_base`

catalina.propertiesファイルのあるcatalinaベースです。`${catalina_base}/conf/catalina.properties`で各リソースの値が管理されます。

必須指定です。

##### `value`
プロパティの値です。

必須指定です。

#### tomcat::config::server

##### `address`

シャットダウンコマンドをリッスンするTCP/IPアドレスを指定します。[address XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes)にマッピングします。

有効なオプション: 文字列。

デフォルト値: `undef`。

##### `address_ensure`

[address XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes)が構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `catalina_base`

管理対象のTomcatインストール先のベースディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '$tomcat::catalina_home'。

##### `class_name`

使用するサーバインプリメンテーションのJavaクラス名を指定します。構成ファイルの[className XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes)にマッピングします。

有効なオプション: Javaクラス名を含む文字列。

デフォルト値: `undef`。

##### `class_name_ensure`

[className XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes)が構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `port`

指定されたシャットダウンコマンドをリッスンするポートを指定します。[port XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes)にマッピングします。

有効なオプション: ポート番号を含む文字列。

デフォルト値: `undef`。

##### `server_config`

管理対象のserver.xmlファイルを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '${catalina_base}/config/server.xml'。

##### `shutdown`

指定されたアドレスおよびポートから受信した場合にTomcatをシャットダウンするコマンドを指定します。[shutdown XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes)にマッピングします。

有効なオプション: 文字列。

デフォルト値: `undef`。

#### tomcat::config::server::connector

##### `additional_attributes`

Connectorに追加するその他の属性を指定します。

有効なオプション: '< attribute >' => '< value >'ペアのハッシュ値。

デフォルト値: `{}`。

##### `attributes_to_remove`

要素から削除する属性の配列を指定します。

有効なオプション: 文字列の配列。

デフォルト値: `[]`。

##### `catalina_base`

管理対象のTomcatインストール先のベースディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '$::tomcat/catalina_home'。

##### `connector_ensure`

[Connector XML要素](http://tomcat.apache.org/tomcat-8.0-doc/connectors.html)が構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `parent_service`

ConnectorをどのService要素下にネストするかを指定します。

有効なオプション: Serviceのname属性を含む文字列。

デフォルト値: 'Catalina'。

##### `port`

*`connector_ensure`が`true`か'present'に設定されている場合、必須です。* サーバソケットを作成するTCPポートを指定します。[port XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#Common_Attributes)にマッピングします。

有効なオプション: 文字列。

##### `protocol`

受信トラフィックの処理に使用するプロトコルを指定します。[protocol XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#Common_Attributes)にマッピングします。

有効なオプション: 文字列。

デフォルト値: `$name`。

##### `purge_connectors`

定義されたプロトコルと一致するが、異なるポートを持つ未管理のConnector要素を構成ファイルからパージするかどうかを指定します。

有効なオプション: `true`と`false`。

デフォルト値: `false`。

##### `server_config`

管理対象のserver.xmlファイルを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '${catalina_base}/config/server.xml'。

#### tomcat::config::server::context

##### `additional_attributes`

Contextに追加するその他の属性を指定します。

有効なオプション: '< attribute >' => '< value >'ペアのハッシュ値。

デフォルト値: `{}`。

##### `attributes_to_remove`

要素から削除する属性の配列を指定します。

有効なオプション: 文字列の配列。

デフォルト値: `[]`。

##### `catalina_base`

管理対象のTomcatインストール先のベースディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '$::tomcat/catalina_home'。

##### `context_ensure`

[Context XML要素](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html)が構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `doc_base`

Document Base (Context Root)ディレクトリ、もしくはアーカイブファイルを指定します。[docBase XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Common_Attributes)にマッピングします。

有効なオプション: パス(絶対パスまたは所有HostのappBaseディレクトリからの相対パス)を含む文字列。

デフォルト値: `$name`。

##### `parent_engine`

ContextをどのEngine要素下にネストするかを指定します。`parent_host`が指定されている場合のみ有効です。

有効なオプション: Engineのname属性を含む文字列。

デフォルト値: `undef`。

##### `parent_host`

ContextをどのHost要素下にネストするかを指定します。

有効なオプション: Hostのname属性を含む文字列。

デフォルト値: `undef`。

##### `parent_service`

ContextをどのService XML要素下にネストするかを指定します。

有効なオプション: Serviceのname属性を含む文字列。

デフォルト値: 'Catalina'。

##### `server_config`

管理対象のserver.xmlファイルを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '${catalina_base}/config/server.xml'。

#### tomcat::config::server::engine

##### `background_processor_delay`

このエンジンとその子コンテナで、backgroundProcessメソッドを呼び出す際の遅延時間を指定します。[backgroundProcessorDelay XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes)にマッピングします。

有効なオプション: 整数(秒単位)。

デフォルト値: `undef`。

##### `background_processor_delay_ensure`

[backgroundProcessorDelay XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes)が構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `catalina_base`

管理対象のTomcatインストール先のベースディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '$::tomcat::catalina_home'。

##### `class_name`

使用するサーバインプリメンテーションのJavaクラス名を指定します。[className XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes)にマッピングします。

有効なオプション: Javaクラス名を含む文字列。

デフォルト値: `undef`。

##### `class_name_ensure`

[className XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes)が構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `default_host`

**必須**。サーバ上に存在するがこの設定ファイルに定義されていないホスト名を宛先とするリクエストを処理するホストを指定します。Engineの[defaultHost XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes)にマッピングします。

有効なオプション: ホスト名を含む文字列。

##### `engine_name`

Engineの論理名を指定します。ログやエラーに使用されます。[name XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes)にマッピングします。

有効なオプション: 文字列。

デフォルト値: 定義タイプに受け渡された`name`。

##### `jvm_route`

負荷分散のセッションアフィニティを有効にする識別子を指定します。[jvmRoute XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes)にマッピングします。

有効なオプション: 文字列。

デフォルト値: `undef`。

##### `jvm_route_ensure`

[jvmRoute XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes)が構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `parent_service`

EngineをどのService要素下にネストするかを指定します。

有効なオプション: Serviceのname属性を含む文字列。

デフォルト値: 'Catalina'。

##### `server_config`

管理対象のserver.xmlファイルを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '${catalina_base}/config/server.xml'。

##### `start_stop_threads`

子Host要素を並列起動するために、Engineが使用するスレッド数を設定します。[startStopThreads XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes)にマッピングします。

有効なオプション: 文字列。

デフォルト値: `undef`。

##### `start_stop_threads_ensure`

[startStopThreads XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes)が構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

#### tomcat::config::server::globalnamingresource

'$CATALINA_BASE/conf/server.xml'のGlobalNamingResources Resource要素を構成します。

##### `ensure`

指定したXML要素が構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `resource_name`

Puppetリソースの`$name`から通常取得されるglobalnamingresource名をオーバーライドします(任意指定)。

##### `catalina_base`

Tomcatインスタンスのベースディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '$::tomcat::catalina_home'。

##### `type`

作成する要素のタイプを指定します。

有効なオプション: `Resource`、`Environment`、またはその他の有効なノード。

デフォルト値: `Resource`。

>注: 入力した値がそのまま構成に使用されます。大文字小文字が正しいことを確認してください。

##### `additional_attributes`

Hostに追加するその他の属性を指定します。

有効なオプション: '< attribute >' => '< value >'ペアのハッシュ値。

デフォルト値: `{}`。

##### `attributes_to_remove`

要素から削除する属性の配列を指定します。

有効なオプション: 文字列の配列。

デフォルト値: `[]`。

##### `server_config`

管理対象のserver.xmlファイルを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '${catalina_base}/config/server.xml'。

#### tomcat::config::server::host

##### `additional_attributes`

Hostに追加するその他の属性を指定します。

有効なオプション: '< attribute >' => '< value >'ペアのハッシュ値。

デフォルト値: `{}`。

##### `aliases`

そのHostの[Host Name Aliases](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Host_Name_Aliases)リストを指定する任意指定の配列です。省略した場合、現在定義されているAliasは変更されません。指定した場合、Aliasのリストにはこの配列の内容がそのまま設定されます。そのため、たとえば、空の配列を指定すると、あるHostがAliasを設定しないよう明示的に強制できます。

##### `app_base`

*[`host_ensure`](#host_ensure)が`false`または'absent'に設定されている場合を除き、指定は必須です。* 仮想ホストのApplication Baseディレクトリを指定します。[appBase XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Common_Attributes)にマッピングします。

有効なオプション: 文字列。

##### `attributes_to_remove`

要素から削除する属性の配列を指定します。

有効なオプション: 文字列の配列。

デフォルト値: `[]`。

##### `catalina_base`

管理対象のTomcatインストール先のベースディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '$::tomcat::catalina_home'。

##### `host_ensure`

仮想ホスト([Host XML要素](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Introduction))が構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `host_name`

DNSサーバに登録されている仮想ホストのネットワーク名を指定します。[name XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Common_Attributes)にマッピングします。 

有効なオプション: 文字列。

デフォルト値: 定義タイプに受け渡された'name'。

##### `parent_service`

HostをどのService要素下にネストするかを指定します。 

有効なオプション: Serviceのname属性を含む文字列。

デフォルト値: 'Catalina'。

##### `server_config`

管理対象のserver.xmlファイルを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '${catalina_base}/config/server.xml'。

#### tomcat::config::server::listener

##### `additional_attributes`

Listenerに追加するその他の属性を指定します。

有効なオプション: '< attribute >' => '< value >'ペアのハッシュ値。

デフォルト値: `{}`。

##### `attributes_to_remove`

要素から削除する属性の配列を指定します。

有効なオプション: 文字列の配列。

デフォルト値: `[]`。

##### `catalina_base`

Tomcatインストール先のベースディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '$::tomcat::catalina_home'。

##### `class_name`

使用するサーバインプリメンテーションのJavaクラス名を指定します。Listener要素の[className XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/listeners.html#Common_Attributes)にマッピングします。

有効なオプション: Javaクラス名を含む文字列。

デフォルト値: `$name`。

##### `listener_ensure`

[Listener XML要素](http://tomcat.apache.org/tomcat-8.0-doc/config/listeners.html)が構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `parent_engine`

ListenerをどのEngine要素下にネストするかを指定します。 

有効なオプション: Engineのname属性を含む文字列。

デフォルト値: `undef`。

##### `parent_host`

ListenerをどのHost要素下にネストするかを指定します。

有効なオプション: Hostのname属性を含む文字列。

デフォルト値: `undef`。

##### `parent_service`

ListenerをどのService要素下にネストするかを指定します。`parent_engine`または`parent_host`が指定されている場合のみ有効です。

有効なオプション: Serviceのname属性を含む文字列。

デフォルト値: 'Catalina'。

##### `server_config`

管理対象のserver.xmlファイルを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '${catalina_base}/config/server.xml'。

#### tomcat::config::server::realm

##### `additional_attributes`

Realm要素に追加するその他の属性を指定します。

有効なオプション: '< attribute >' => '< value >'ペアのハッシュ値。

デフォルト値: `{}`。

##### `attributes_to_remove`

要素から削除する属性の配列を指定します。

有効なオプション: 文字列の配列。

デフォルト値: `[]`。

##### `catalina_base`

Tomcatインストール先のベースディレクトリを指定します。

デフォルト値: '$::tomcat::catalina_home'。

##### `class_name`

使用するRealmインプリメンテーションのJavaクラス名を指定します。 [className XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/realm.html#Common_Attributes)にマッピングします。

有効なオプション: Javaクラス名を含む文字列。

デフォルト値: 定義タイプに受け渡された`name`。

##### `parent_engine`

RealmをどのEngine要素下にネストするかを指定します。

有効なオプション: Engineのname属性を含む文字列。

デフォルト値: 'Catalina'。

##### `parent_host`

RealmをどのHost要素下にネストするかを指定します。

有効なオプション: Hostのname属性を含む文字列。

デフォルト値: `undef`。

##### `parent_realm`

RealmをどのRealm要素下にネストするかを指定します。

有効なオプション: Realm要素のclassName属性を含む文字列。

デフォルト値: `undef`。

##### `parent_service`

このRealm要素をどのService要素下にネストするかを指定します。

有効なオプション: Serviceのname属性を含む文字列。

デフォルト値: 'Catalina'。

##### `purge_realms`

未管理のRealm要素を構成ファイルからパージするかどうかを指定します。

有効なオプション: `true`と`false`。

デフォルト値: `false`。

##### `realm_ensure`

Realm要素が構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `server_config`

管理対象のserver.xmlファイルを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '${catalina_base}/config/server.xml'。

#### tomcat::config::server::service

##### `catalina_base`

Tomcatインストール先のベースディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '$::tomcat::catalina_home'。

##### `class_name`

使用するサーバインプリメンテーションのJavaクラス名を指定します。[className XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html#Common_Attributes)にマッピングします。

有効なオプション: Javaクラス名を含む文字列。

デフォルト値: `undef`。

##### `class_name_ensure`

[className XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html#Common_Attributes)が構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `server_config`

管理対象のserver.xmlファイルを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '${catalina_base}/config/server.xml'。

##### `service_ensure`

[Service要素](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html#Introduction)が構成ファイルに存在するかどうかを指定します。 

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

#### tomcat::config::server::tomcat_users

##### `catalina_base`

Tomcatインストール先のベースディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '$::tomcat::catalina_home'。

##### `element`

管理する要素のタイプを指定します。

有効なオプション: 'user'または'role'。

デフォルト値: `user`。

##### `element_name`

要素のユーザ名(`element`が'role'に設定されている場合はロール名)を設定します。

有効なオプション: 文字列。

デフォルト値: `$name`。

##### `ensure`

指定したXML要素が構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `file`

管理する構成ファイルを指定します。

有効なオプション: 完全修飾パスを含む文字列。

デフォルト値: '$CATALINA_BASE/conf/tomcat-users.xml'。

##### `group`

構成ファイルのグループを指定します。

デフォルト値: `$::tomcat::group`。

##### `manage_file`

指定された構成ファイルが存在しない場合、そのファイルを作成するかどうかを指定します。Puppeのネイティブ[`file`リソースタイプ](https://docs.puppetlabs.com/references/latest/type.html#file)をデフォルトのパラメータとともに使用します。

有効なオプション: `true`と`false`。

デフォルト値: `true`。

##### `owner`

構成ファイルの所有者を指定します。

デフォルト値: `$::tomcat::user`。

##### `password`

ユーザ要素のパスワードを指定します。

有効なオプション: 文字列。

デフォルト値: `undef`。

##### `roles`

1つまたは複数のロールを指定します。`element`が'role'または'user'に設定されている場合のみ有効です。

有効なオプション: 文字列の配列。

デフォルト値: `[]`。

#### tomcat::config::server::valve

##### `additional_attributes`

Valveに追加するその他の属性を指定します。

有効なオプション: '< attribute >' => '< value >'ペアのハッシュ値。

デフォルト値: `{}`。

##### `attributes_to_remove`

要素から削除する属性の配列を指定します。

有効なオプション: 文字列の配列。

デフォルト値: `[]`。

##### `catalina_base`

Tomcatインストール先のベースディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: `$::tomcat::catalina_home`。

##### `class_name`

使用するサーバインプリメンテーションのJavaクラス名を指定します。[className XML属性](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Access_Logging/Attributes)にマッピングします。

有効なオプション: Javaクラス名を含む文字列。

デフォルト値: 定義タイプに受け渡された'name'。

##### `parent_host`

Valveをどの仮想ホスト下にネストするかを指定します。

有効なオプション: Host要素の名前を含む文字列。

デフォルト値: ホストを指定しない場合、Valve要素は指定された親ServiceのEngine下にネストされます。

##### `parent_service`

ValveをどのService要素下にネストするかを指定します。

有効なオプション: Service要素の名前を含む文字列。

デフォルト値: 'Catalina'。

##### `parent_context`

ValveをどのContext要素下にネストするかを指定します。

有効なオプション: Context要素の名前(docbase属性と一致)を含む文字列。

デフォルト値: コンテキストを指定しない場合、Valve要素は、Parent Host (定義されている場合)下または指定された親ServiceのEngine下にネストされます。

##### `server_config`

管理対象のserver.xmlファイルを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '${catalina_base}/config/server.xml'。

##### `valve_ensure`

Valveが構成ファイルに存在するかどうかを指定します。[Valve XML要素](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Introduction)にマッピングします。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

#### tomcat::config::context

他の`tomcat::config::context::*`定義タイプのために、`${catalina_base}/conf/context.xml`の構成Context要素を指定します。

##### `catalina_base`

Tomcatインストール先のルートディレクトリを指定します。

#### tomcat::config::context::manager
指定されたxml構成のManager要素を指定します。

##### `ensure`

Manager要素を追加しようとしているのか、削除しようとしているのかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `catalina_base`

Tomcatインストール先のルートディレクトリを指定します。

デフォルト値: '$tomcat::catalina_home'。

##### `manager_classname`

作成するManagerの名前です。

デフォルト値: `$name`。

##### `additional_attributes`

Managerに追加するその他の属性を指定します。

'attribute' => 'value'形式のハッシュ値である必要があります。

任意指定

##### `attributes_to_remove`

要素から削除する属性の配列を指定します。

有効なオプション: 文字列の配列。

デフォルト値: `[]`。

#### tomcat::config::context::environment

`${catalina_base}/conf/context.xml`のEnvironment要素を指定します。

##### `ensure`

Environment要素を追加しようとしているのか、削除しようとしているのかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `environment_name`

作成するEnvironmentエントリの名前。`java:comp/env`コンテキストに対して相対的な名前です。

デフォルト値: `$name`。

##### `type`

この環境エントリについてWebアプリケーションから予測される完全修飾Javaクラス名。

環境エントリを作成する場合は必須です。

##### `value`

JNDIコンテキストからリクエストされたときに、アプリケーションに表示される値。

環境エントリを作成する場合は必須です。

##### `description`

この環境エントリについて人間が読める形式で説明する任意指定の文字列です。

##### `override`

同じ環境エントリ名に対する`<env-entry>`がここで指定した値をオーバーライドしないようにする(`false`に設定)、任意指定の文字列またはブール値。

デフォルトでは、オーバーライドは許可されます。

##### `catalina_base`

Tomcatインストール先のルートディレクトリを指定します。

デフォルト値: '$tomcat::catalina_home'。

##### `additional_attributes`

Environmentに追加するその他の属性を指定します。

'attribute' => 'value'形式のハッシュ値である必要があります。

任意指定

##### `attributes_to_remove`

要素から削除する属性の配列を指定します。

有効なオプション: 文字列の配列。

デフォルト値: `[]`。

#### tomcat::config::context::resource

`${catalina_base}/conf/context.xml`のResource要素を指定します。

##### `ensure`

Resource要素の追加または削除のどちらを試みるか指定します。 

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `resource_name`

作成するResourceの名前。`java:comp/env`コンテキストに対して相対的な名前です。

デフォルト値: `$name`。

##### `resource_type`

このリソースのルックアップを実行するときにWebアプリケーションから期待される完全修飾Javaクラス名。リソースを作成する場合は必須です。

##### `catalina_base`

Tomcatインストール先のルートディレクトリを指定します。

デフォルト値: '$tomcat::catalina_home'。

##### `additional_attributes`

Valveに追加するその他の属性を指定します。

'attribute' => 'value'形式のハッシュ値である必要があります。 

任意指定

##### `attributes_to_remove`

要素から削除する属性の配列を指定します。

有効なオプション: 文字列の配列。

デフォルト値: `[]`。

#### tomcat::config::context::valve

`${catalina_base}/conf/context.xml`のValve要素を指定します。

##### `ensure`

Valve要素を追加しようとしているのか、削除しようとしているのかを指定します。

有効な値：'present'、'absent'。

デフォルト値：'present'

##### `resource_name`

作成するResourceの名前。java:comp/envコンテキストに対して相対的な名前です。

デフォルト値: `$name`

##### `resource_type`

このリソースのルックアップを実行するときにWebアプリケーションから期待される完全修飾Javaクラス名。リソースを作成する場合は必須です。

##### `catalina_base`

Tomcatインストール先のルートディレクトリを指定します。

デフォルト値: `$tomcat::catalina_home`

##### `additional_attributes`

Valveに追加するその他の属性を指定します。

有効なオプション: '< attribute >' => '< value >'ペアのハッシュ値。

デフォルト値: `{}`。

##### `attributes_to_remove`

要素から削除する属性の配列を指定します。

有効なオプション: 文字列の配列。

デフォルト値: `[]`。

#### tomcat::config::context::resourcelink

指定されたxml構成のResourceLink 要素を指定します。

##### `ensure`

ResourceLink要素の追加または削除のどちらを試みるかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `catalina_base`

Tomcatインストール先のルートディレクトリを指定します。

デフォルト値: `$tomcat::catalina_home`。

##### `resourcelink_name`

作成するResourceLinkの名前。`java:comp/env`コンテキストに対して相対的な名前です。

デフォルト値: `$name`。

##### `resourcelink_type`

このリソースリンクのルックアップを実行するときにWebアプリケーションから期待される完全修飾Javaクラス名。

##### `additional_attributes`

Valveに追加するその他の属性を指定します。

'attribute' => 'value'形式のハッシュ値である必要があります。

任意指定

##### `attributes_to_remove`

要素から削除する属性の配列を指定します。

有効なオプション: 文字列の配列。

デフォルト値: `[]`。

#### `tomcat::install`

ソースApache Tomcat tarballから、指定されたディレクトリにソフトウェアをインストールします。tomcatパッケージをインストールする場合にも使用できます。

その後、 `tomcat::instance`を使用して、`tomcat::instance::catalina_home`を`tomcat::install`によって管理されているディレクトリに指定することで、Tomcatインスタンスをインストールファイルから作成できます。

##### `catalina_home`

インスタンスの作成元となるTomcatインストールディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '$::tomcat::catalina_home'。

##### `install_from_source`

ソースからインストールするか、パッケージからインストールするか指定します。`true`に設定した場合、`source_url`、`source_strip_first_dir`、`user`、`group`、`manage_user`、`manage_group`パラメータが使用されます。`false`に設定した場合、`package_ensure`、`package_name`、`package_options`パラメータが使用されます。

有効なオプション: `true`と`false`。

デフォルト値: `true`。

##### `source_url`

シングルインスタンスモードの場合: *`install_from_source`が`true`に設定されている場合は必須です。* インストール元のソースURLを指定します。

有効なオプション: `puppet://`、`http(s)://`、または`ftp://`のURLを含む文字列。

##### `source_strip_first_dir`

展開時にtarballの最上位ディレクトリを除去するかどうかを指定します。 `install_from_source`が`true`に設定されているときのみ有効です。

有効なオプション: `true`と`false`。

デフォルト値: `true`。

##### `proxy_server`

Tomcatのバイナリをダウンロードするときに使用するプロキシサーバを指定します。例：'https://example.com:8080'

デフォルト値: `undef`。

##### `proxy_type`

`proxy_server` が使用するプロキシサーバのタイプを指定します。通常、これには`proxy_server` のURIで指定されたプロトコルがデフォルトで設定されます。

デフォルト値: `proxy_server`から自動検出。

有効なオプション: 'none', 'http', 'https', 'ftp'。

##### `allow_insecure`

ソースコードのダウンロード時にHTTPSエラーを無視する必要がある場合に指定します。

デフォルト値: `false`。

有効なオプション: `true`と`false`。

##### `user`

ソースインストールディレクトリの所有者を指定します。

デフォルト値: `$::tomcat::user`。

##### `group`

ソースインストールディレクトリのグループを指定します。

デフォルト値: `$::tomcat::group`。

##### `manage_user`

ユーザをこのモジュールで管理するかどうかを指定します。

デフォルト値: `$::tomcat::manage_user`。

##### `manage_group`

グループをこのモジュールで管理するかどうかを指定します。

デフォルト値: `$::tomcat::manage_group`。

##### `manage_home`

catalina_homeディレクトリをpuppetで管理するかどうかを指定します。ネットワークファイルシステム環境では推奨されないことがあります。

デフォルト値: `true`。

##### `package_ensure`

指定されたパッケージをインストールするかどうかを指定します。`install_from_source`が`false`に設定されている場合のみ有効です。Puppetのネイティブ[`package`リソースタイプ](https://docs.puppetlabs.com/references/latest/type.html#package)の`ensure`パラメータにマッピングします。

デフォルト値: 'present'。

##### `package_name`

*`install_from_source`が`false`に設定されている場合は必須です。* インストールするパッケージを指定します。

有効なオプション: 有効なパッケージ名を含む文字列。

##### `package_options`

*`install_from_source`が`true`に設定されている場合は使用されません。* 生成されたパッケージリソースに使用する追加オプションを指定します。指定できる値については、[`package`リソースタイプ](https://docs.puppetlabs.com/references/latest/type.html#package-attribute-install_options)の説明を参照してください。

#### tomcat::instance

tomcatインスタンスを宣言します。

単一のtomcatインストールで1つのインスタンスを実行する場合(「シングルインスタンス」)、または、 単一のtomcatインストールでそれぞれ独自のディレクトリ構造を持つ複数のインスタンスを実行する場合(「マルチインスタンス」)の2通りの使用方法があります。

- single-instance: `catalina_home`と`catalina_base`の両方が`tomcat::install`ディレクトリを指している状態で`tomcat::instance`が宣言された場合、シングルインスタンス構成です。
- multi-instance: `catalina_home`が`tomcat::install`と同じディレクトリを指し、`catalina_base`が別のディレクトリを指した状態で`tomcat::instance`が宣言された場合、Apache Tomcatソフトウェアのインスタンスとして構成されることになります。この方法で、単一のインストールで複数のインスタンスを作成できます。`tomcat::install`宣言では、`tomcat::instance`宣言がインストールディレクトリにアクセスできるユーザおよび/またはグループを使用する必要があります。

##### `catalina_base`

Tomcatインスタンスの`$CATALINA_BASE`を指定します。この場所で、ログ、構成ファイル、'webapps'ディレクトリが管理されます。シングルインスタンスのインストールの場合、`catalina_home`パラメータと同一になります。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: `$catalina_home`。

##### `catalina_home`

Apache Tomcatソフトウェアが`tomcat::install`リソースによってインストールされるディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '$::tomcat::catalina_home'。

##### `dir_list`

 `catalina_base`の下に、インスタンスを管理するためのサブディレクトリを指定します(`manage_dirs`ブール値では無効)。

有効なオプション: 文字列。それぞれが`catalina_base`の相対サブディレクトリになります。

デフォルト値: `['bin','conf','lib','logs','temp','webapps','work']`。

##### `dir_mode`

`catalina_base`の下のインスタンス用管理サブディレクトリのモードを指定します(`dir_list`で指定され、`manage_dirs`ブール値では無効)。

有効なオプション: 標準Linuxモードを含む文字列。

デフォルト値: '2770'。

##### `copy_from_home_list`

`catalina_home`から`catalina_base`へインスタンスをコピーするための構成ファイルのフルパスを指定します(`manage_copy_from_home`ブール値では無効)。

有効なオプション: パスとファイル名を含む文字列。

デフォルト値:
    [ '${_catalina_base}/conf/catalina.policy',
      '${_catalina_base}/conf/context.xml',
      '${_catalina_base}/conf/logging.properties',
      '${_catalina_base}/conf/server.xml',
      '${_catalina_base}/conf/web.xml',
    ]

##### `copy_from_home_mode`

`catalina_home` から`catalina_base`へ初期構成ファイルをコピーする場合のファイルモードを指定します。

有効なオプション: 標準Linuxモードを含む文字列。

デフォルト値: '0660'。 

##### `group`

インスタンスディレクトリおよびファイルのグループを指定します。

デフォルト値: `$::tomcat::group`。

##### `java_home`

`tomcat::service`インスタンスの宣言時にjava homeを使用するかどうかを指定します。[tomcat::service](#tomcatservice)を参照してください。

##### `manage_base`

catalina_baseディレクトリをpuppetで管理するかどうかを指定します。ネットワークファイルシステム環境では推奨されないことがあります。

デフォルト値: `true`。


##### `manage_dirs`

`catalina_base`のサブディレクトリをtomcat::instanceの一部として管理するかどうかを指定します。デフォルトのディレクトリは`dir_list`に記載されています。

有効なオプション: `true`と`false`。

##### `manage_copy_from_home`

`catalina_home` から`catalina_base`へ初期構成ファイルをコピーするかどうかを指定します。

有効なオプション: ブール値。


デフォルト値: `true`。

##### `manage_group`

グループをこのモジュールで管理するかどうかを指定します。

デフォルト値: `$::tomcat::manage_group`。

##### `manage_properties`

`catalina.properties`ファイルを作成および管理しているかどうかを指定します。`true`の場合、このファイルに加えられたカスタム変更が実行中にオーバーライドされます。

有効なオプション: `true`、`false`。

デフォルト値: `true`。

##### `manage_service`

このインスタンスに対応する`tomcat::service`を宣言するかどうかを指定します。 

有効なオプション: `true`、`false`。

デフォルト値: `true` (マルチインスタンスをインストールする場合)、 `false` (シングルインスタンスをインストールする場合)。

##### `manage_user`

ユーザをこのモジュールで管理するかどうかを指定します。

デフォルト値: `$::tomcat::manage_user`。

##### `use_init`

`tomcat::service`インスタンスの宣言時にinitスクリプトを管理するかどうかを指定します。[tomcat::service](#tomcatservice)を参照してください。

##### `use_jsvc`

`tomcat::service`インスタンスの宣言時にjsvcを使用するかどうかを指定します。

>注: このモジュールはjsvcのコンパイル/インストールは行いません。[tomcat::service](#tomcatservice)を参照してください。

##### `user`

インスタンスディレクトリおよびファイルの所有者を指定します。

デフォルト値: `$::tomcat::user`。

#### tomcat::service

##### `catalina_base`

Tomcatインストール先のベースディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '$::tomcat::catalina_home'。

##### `catalina_home`

Tomcatインストール先のルートディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '$::tomcat::catalina_home'。

##### `java_home`

Javaのインストール場所を指定します。`use_jsvc`が`true`に設定されているときのみ適用されます。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: `undef`。

>注: このパラメータにhomeパスを指定しない場合、Puppetは`-home`スイッチをTomcatに受け渡しません。一部のシステムでは、これにより問題が生じる可能性があるため、このパラメータを指定することを推奨します。

##### `service_enable`

Tomcatサービスを起動時に有効化するかどうかを指定します。`use_init`が`true`に設定されている場合のみ有効です。

有効なオプション: `true`と`false`。

デフォルト値: `use_init`が`true`で、`service_ensure`が'running'または`true`に設定されている場合、`true`。

##### `service_ensure`

Tomcatサービスが実行中かどうかを指定します。Puppetのネイティブ[`service`リソースタイプ](https://docs.puppetlabs.com/references/latest/type.html#service)の`ensure`パラメータにマッピングします。

有効なオプション: 'running'、'stopped'、`true`、`false`。

デフォルト値: 'present'。

##### `service_name`

*`use_init`が`true`に設定されている場合は必須です。* Tomcatサービスの名前を指定します。

有効なオプション: 文字列。

##### `start_command`

サービスを起動するコマンドを指定します。Designates a command to start the service.

有効なオプション: 文字列。

デフォルト値: `use_init`および`use_jsvc`の値によって決まります。

##### `status_command`

サービスのステータスを得るコマンドを指定します。

有効なオプション: 文字列。

デフォルト値: `use_init`および`use_jsvc`の値によって決まります。

##### `stop_command`

サービスを停止するコマンドを指定します。

有効なオプション: 文字列。

デフォルト値: `use_init`および`use_jsvc`の値によって決まります。

##### `use_init`

サービスの管理にパッケージで提供されたinitスクリプトを使用するかどうかを指定します。

 * `$CATALINA_HOME/bin/catalina.sh start`
 * `$CATALINA_HOME/bin/catalina.sh stop`

有効なオプション: `true`と`false`。

デフォルト値: `false`。

>注: tomcatモジュールはinitスクリプトを提供しません。`use_jsvc`と`use_init`の両方が`false`に設定されている場合、tomcatは次のコマンドを使用してサービスの管理を行います。

##### `use_jsvc`

サービスの管理にJsvcを使用するかどうかを指定します。`use_jsvc`と`use_init`の両方が`false`に設定されている場合、tomcatは次のコマンドを使用してサービスの管理を行います。

 * `$CATALINA_HOME/bin/catalina.sh start`
 * `$CATALINA_HOME/bin/catalina.sh stop`

有効なオプション: `true`と`false`。

デフォルト値: `false`。

##### `user`

`use_init => true`のときのjsvcプロセスのユーザ。

#### tomcat::setenv::entry

##### `config_file`

編集する構成ファイルを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: '$::tomcat::catalina_home/bin/setenv.sh。

##### `ensure`

フラグメントが構成ファイルに存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `group`

構成ファイルのグループを指定します。

デフォルト値: `$::tomcat::group`。

##### `order`

構成ファイル内のパラメータの順序を指定します(`order`値が小さいパラメータが先に表示されます)。

有効なオプション: 整数、または整数を含む文字列。

デフォルト値: `10`。

###### `addto`

`param`の先頭に付加される追加の環境変数を定義します。

##### `param`

管理するパラメータを指定します。

有効なオプション: 文字列。

デフォルト値: 定義タイプに受け渡された`name`。

##### `quote_char`

指定された値の前後に付加する文字を指定します。

有効なオプション: 文字列(通常、シングルクォーテーションまたはダブルクォーテーション)。

デフォルト値: (空白)。

##### `user`

構成ファイルの所有者を指定します。

デフォルト値: `$::tomcat::user`。

##### `value`

**必須**。管理対象のパラメータの値を提供します。

有効なオプション: 文字列または配列。配列を渡す場合、半角空白1つで値を区切ります。

##### `doexport`

エントリにエクスポートをアペンドするかどうかを指定します。

有効なオプション: `true`または`false`。

デフォルト値: `true`。

#### `tomcat::war`

##### `allow_insecure`

war tarballのダウンロード時にHTTPSエラーを無視する必要がある場合に指定します。

デフォルト値: `false`、

有効なオプション: `true`と`false`。

##### `app_base`

WARをデプロイする場所を指定します。`deployment_path`と組み合わせて使用することはできません。

有効なオプション: `$CATALINA_BASE`からの相対パスを含む文字列。

デフォルト値: `app_base`を指定しない場合、Puppetは指定された`deployment_path`にWARをデプロイします。それも指定されていない場合は、WARは`${catalina_base}/webapps`にデプロイされます。

##### `catalina_base`

Tomcatインストール先のベースディレクトリを指定します。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: `$::tomcat::catalina_home`。

##### `deployment_path`

WARをデプロイする場所を指定します。`app_base`と組み合わせて使用することはできません。

有効なオプション: 絶対パスを含む文字列。

デフォルト値: `deployment_path`を指定しない場合、Puppetは指定された`app_base`にWARをデプロイします。それも指定されていない場合は、WARは`${catalina_base}/webapps`にデプロイされます。

##### `war_ensure`

WARが存在するかどうかを指定します。

有効なオプション: 'present'、'absent'。

デフォルト値: 'present'。

##### `war_name`

WARの名前を指定します。

有効なオプション: '.war'で終わるファイル名を含む文字列。

デフォルト値: 定義タイプに受け渡された`name`。

##### `war_purge`

展開されたWARディレクトリをパージするかどうかを指定します。`war_ensure`が'absent'または`false`の場合のみ適用されます。

有効なオプション: `true`と`false`。

デフォルト値: `true`。

>注: Tomcatが実行中でautoDeployが`true`に設定されている場合、このパラメータを`false`に指定しても、展開されたWARディレクトリがTomcatによって削除されるのを回避することはできません。

##### `war_source`

*`war_ensure`が`false`または'absent'に設定されている場合を除き、必須です。* WARのデプロイ元のソースを指定します。

有効なオプション: `puppet://`、`http(s)://`、または`ftp://`のURLを含む文字列。

##### `user`

tomcat warファイルの'owner'。

デフォルト値: 'tomcat'。

##### `group`

tomcat warファイルの'group'所有者。

デフォルト値: 'tomcat'。


## 制限事項

このモジュールでは、Unix系システムでのTomcatインストールのみサポートされています。`tomcat::config::server*`定義タイプには、Augeasバージョン1.0.0以降が必要です。

### マルチインスタンス

一部のTomcatパッケージでは、複数のインスタンスをインストールすることが許可されていません。Tomcatをソースからインストールすることで、この制約を回避できます。

## 開発

Puppet ForgeのPuppet Labsモジュールは、オープンプロジェクトです。プロジェクトをさらに発展させるには、コミュニティへの貢献が不可欠です。Puppetが役立つ可能性のある膨大な数のプラットフォーム、無数のハードウェア、ソフトウェア、デプロイメント構成に我々がアクセスすることはできません。

お使いの環境でモジュールが動作するよう、変更点をできる限り簡単に貢献していただけるよう心がけています。全体を把握しやすくするため、貢献する方々に守っていただきたいいくつかの指針があります。

詳細については、[モジュール貢献ガイド](https://docs.puppetlabs.com/forge/contributing.html)を参照してください。

### 貢献者のご紹介

すでに貢献してくださった方々のリストを[貢献者リスト](https://github.com/puppetlabs/puppetlabs-tomcat/graphs/contributors)でご覧いただけます。

### テストの実行

機能検証のため、本プロジェクトには[rspec-puppet](http://rspec-puppet.com/)と[beaker-rspec](https://github.com/puppetlabs/beaker-rspec)の両方についてのテストが含まれています。詳細な情報については、それぞれのドキュメントをご覧ください。

クイックスタートガイド:

```bash
gem install bundler
bundle install
bundle exec rake spec
bundle exec rspec spec/acceptance
RS_DEBUG=yes bundle exec rspec spec/acceptance
```