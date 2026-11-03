# ntp

#### 目次


1. [モジュールの概要 - ntpモジュールについて](#モジュールの概要)
1. [セットアップ - ntpを開始するにあたっての基本設定](#セットアップ)
1. [利用例 - 設定オプションと追加機能](#利用例)
1. [参照 - モジュールのクラスやパラメータの説明](#参照)
1. [制限事項 - OSの互換性など](#制限事項)
1. [開発 - モジュールへの貢献方法](#開発)


## モジュールの概要

このモジュールは様々なOSや環境において、NTPサービスをインストール、設定、管理するものです。

## セットアップ

### ntpモジュールの利用方法

`include ntp`と記述するだけで利用可能です。参照するNTPサーバは、以下のようにパラメータで指定します。

```puppet
class { 'ntp':
  servers => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
}
```

## 利用例

ntpモジュールのすべてのパラメータは、メインクラスである`ntp`クラスに含まれているため、ntpモジュールで利用可能な全てのオプションを自由に設定できます。以下にユースケースを示します。

### NTPをインストールして有効にする

```puppet
include ntp
```

### NTPサーバを変更する

```puppet
class { 'ntp':
  servers => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
}
```

### 接続可能ユーザ数を制限する

```puppet
class { 'ntp':
  servers  => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
  restrict => ['127.0.0.1'],
}
```

### 参照不可のNTPクライアントをインストールする

```puppet
class { 'ntp':
  servers   => ['ntp1.corp.com', 'ntp2.corp.com'],
  restrict  => [
    'default ignore',
    '-6 default ignore',
    '127.0.0.1',
    '-6 ::1',
    'ntp1.corp.com nomodify notrap nopeer noquery',
    'ntp2.corp.com nomodify notrap nopeer noquery'
  ],
}
```

### 特定のインターフェイスでのみLISTENする

Openstackノードには多数の仮想インターフェイスが存在する場合があるため、NTPサーバでLISTENするインターフェイスを特定のインターフェイスに制限するのは有効な手段です。

```puppet
class { 'ntp':
  servers  => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
  interfaces => ['127.0.0.1', '1.2.3.4']
}
```

### Puppetによるサービスの制御を中止する

```puppet
class { 'ntp':
  servers        => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
  restrict       => ['127.0.0.1'],
  service_manage => false,
}
```

### ntpパッケージはインストールせず、設定とサービス起動のみ実行する

```puppet
class { 'ntp':
  package_manage => false,
}
```

### カスタムテンプレートにパラメータを渡す

```puppet
class { 'ntp':
  servers         => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
  restrict        => ['127.0.0.1'],
  service_manage  => false,
  config_epp      => 'different/module/custom.template.epp',
}
```

## 参照

### クラス

#### パブリッククラス

* ntp: その他すべてのクラスを含むメインクラス。

#### プライベートクラス

* ntp::install: パッケージのインストール
* ntp::config: 設定ファイルのセットアップ
* ntp::service: サービスの制御

### パラメータ

`ntp`クラスでは、以下のパラメータを使用できます。

#### `authprov`

任意

データタイプ: 文字列

NTPdの一部のバージョン(Novell DSfWなど)で、W32Timeとの互換性を確保できます。
デフォルト値: `undef`

#### `broadcastclient`

データタイプ: 真偽値(boolean)

あらゆるローカルインターフェイスでブロードキャストサーバのメッセージを受信できるようになります。

デフォルト値: `false`

#### `config`

データタイプ: Stdlib::Absolutepath.

NTPの構成情報を含むファイルを指定します。

デフォルト値: '/etc/ntp.conf' (Solaris: '/etc/inet/ntp.conf')

#### `config_dir`

任意

データタイプ: Stdlib::Absolutepath.

NTP構成ファイルのディレクトリを指定します。

デフォルト値: `undef`

#### `config_epp`

任意

データタイプ: 文字列

構成ファイルのEPPテンプレートへの絶対パスまたは相対パスを指定します(値の例: 'ntp/ntp.conf.epp')。このパラメータと`config_template`パラメータの**両方**を指定すると、バリデーションエラーが発生します。

#### `config_file_mode`

データタイプ: 文字列

設定ファイルのファイルモードを指定します。

デフォルト値: '0664'

#### `config_template`

任意

データタイプ: 文字列

構成ファイルのERBテンプレートへの絶対パスまたは相対パスを指定します(値の例: 'ntp/ntp.conf.erb')。このパラメータと`config_epp`パラメータの**両方**を指定すると、バリデーションエラーが発生します。

#### `disable_auth`

データタイプ: 真偽値(boolean)

ブロードキャストクライアントモード、マルチキャストクライアントモード、対象モード/ピアモードの暗号化認証を無効にします。

#### `disable_dhclient`

データタイプ: 真偽値(boolean)

`dhclient.conf`内の`ntp-servers`を無効にすることによって、DhclientがNTPの設定を管理できないようにします。

#### `disable_kernel`

データタイプ: 真偽値(boolean)

カーネルによる時刻の調整を無効にします。

#### `disable_monitor`

データタイプ: 真偽値(boolean)

NTP内のモニタリング機能を無効にします。

デフォルト値: `true`

#### `driftfile`

データタイプ: Stdlib::Absolutepath.

NTP driftfileの保存場所を指定します。

デフォルト値: '/var/lib/ntp/drift' (AIX: 'ntp::driftfile:', Solaris: '/var/ntp/ntp.drift').

#### `enable_mode7`

データタイプ: 真偽値(boolean)

非推奨のntpdcプログラムによって使用される、NTPモード7の実装固有リクエストの処理を有効化します。

デフォルト値: `false`

#### `fudge`

任意

データタイプ: 配列[文字列]

個々のクロックドライバの追加情報を提供します。

デフォルト値: [ ]

#### `iburst_enable`

データタイプ: 真偽値(boolean)

すべてのNTPピアのiburstオプションを有効にするかどうかを指定します。

デフォルト値: `false` (AIX、Debian: `true`)

#### `interfaces`

データタイプ: 配列[文字列]

NTPがLISTENする1つ以上のネットワークインターフェイスを指定します。

デフォルト値: [ ]

#### `interfaces_ignore`

データタイプ: 配列[文字列]

1つ以上のNTPリスナー設定で無視するパターン(例: all、wildcard、ipv6)を指定します。

デフォルト値: [ ]

#### `keys`

データタイプ: 配列[文字列]

鍵ファイルに鍵を配布します。

デフォルト値: [ ]

#### `keys_controlkey`

任意

データタイプ: Ntp::Key_id

ntpqユーティリティと共に使用する鍵識別子(値の範囲: 1～65,534)を指定します。

デフォルト値: ' '

#### `keys_enable`

データタイプ: 真偽値(boolean)

鍵による認証を有効にするかどうかを指定します。

デフォルト値: `false`

#### `keys_file`

Stdlib::Absolutepath.

MD5鍵ファイルの完全パスと保存場所を指定します。MD5鍵ファイルには、対称鍵暗号の使用時にntpd、ntpqおよびntpdcが使用する鍵と鍵識別子が含まれています。

デフォルト値: '/etc/ntp.keys' (RedHat、Amazon: `/etc/ntp/keys`)

#### `keys_requestkey`

任意

データタイプ: Ntp::Key_id

ntpdcユーティリティプログラムと共に使用する鍵識別子(値の範囲: 1～65,534)を指定します。

デフォルト値: ' '

#### `keys_trusted`

任意

データタイプ: 配列[Ntp::Key_id]

NTPが信頼している1つ以上の鍵を提供します。

デフォルト値: [ ]

#### `leapfile`

任意

データタイプ: Stdlib::Absolutepath.

NTPが使用する「うるう秒ファイル」を指定します。

デフォルト値: ' '

#### `logfile`

任意

データタイプ: Stdlib::Absolutepath.

NTPがsyslogの代わりに使用するログファイルを指定します。

デフォルト値: ' '

#### `minpoll`

任意

データタイプ: Ntp::Poll_interval

Puppetをアップストリームサーバの規格外の最小ポーリング間隔に設定します(値: 4～17)。
デフォルト: `undef`

#### `maxpoll`

任意

データタイプ: Ntp::Poll_interval

アップストリームサーバの規格外の最大ポーリング間隔に設定します(値: 4～17)。
デフォルトオプション: `undef`(FreeBSD: 9)

#### `ntpsigndsocket`

任意

データタイプ: Stdlib::Absolutepath.

NTPがntpsigndsocketパスのソケットを使用してパケットに署名するよう設定します。NTPがソケットに署名するよう設定されていなければなりません。値: ソケットディレクトリへのパス(例: Samba: `usr/local/samba/var/lib/ntp_signd/`)。

デフォルト値: `undef`

#### `package_ensure`

データタイプ: 文字列

NTPパッケージをインストールするかどうか、インストールする場合はどのバージョンをインストールするかを指定します(値: 'present'、'latest'、または特定のバージョン番号)。

デフォルト値: 'present'

#### `package_manage`

データタイプ: 真偽値(boolean)

NTPパッケージを管理するかどうか指定します。

デフォルト値: `true`

#### `package_name`

データタイプ: 配列[文字列]

管理するNTPパッケージを指定します。

デフォルト値: ['ntp'] (AIX: 'bos.net.tcp.client'、Solaris: [ 'SUNWntp4r'、'SUNWntp4u' ])

#### `panic`

任意
データタイプ: 整数[0]

クロックキューが大きすぎる場合にNTPでパニックを発生させ終了させるかどうか指定します。この指定は`tinker`オプションが`true`に設定されている場合のみ、または仮想マシン環境でのみ適用されます。

デフォルト値: `undef` (仮想環境: 0)

#### `pool`

任意

データタイプ: 配列[文字列]

ローカルクロックを同期させるNTPサーバプールのリスト

デフォルト値: [ ]

#### `peers`

データタイプ: 配列[文字列]

ローカルクロックを同期させるNTPサーバのリスト

#### `preferred_servers`

データタイプ: 配列[文字列]

1つ以上の優先ピアを指定します。Puppetによって`servers`配列内の一致する項目の最後に'prefer'が追加されます。

デフォルト値: [ ]

#### `noselect_servers`

配列[文字列]で、同期させない1つ以上のピアを指定します。Puppetによって`servers`配列内の一致する項目の最後に'noselect'が追加されます。デフォルト値: [ ]

#### `restrict`

データタイプ: 配列[文字列]

NTP設定の1つ以上の`restrict`オプションを指定します。Puppetによって各項目の先頭に'restrict'が追加されるため、リストする必要があるのは制限事項の内容のみです。

ほとんどのオペレーティングシステムでのデフォルト値:

```shell
[
  'default kod nomodify notrap nopeer noquery',
  '-6 default kod nomodify notrap nopeer noquery',
  '127.0.0.1',
  '-6 ::1',
]
```

AIXシステムのデフォルト値:

```shell
[
  'default nomodify notrap nopeer noquery',
  '127.0.0.1',
]
```

#### `servers`

データタイプ: 配列[文字列]

NTPピアとして使用する1つ以上のサーバを指定します。

デフォルト値: オペレーティングシステムによって異なります。

#### `service_enable`

データタイプ: 真偽値(boolean)

起動時にNTPサービスを有効にするかどうか指定します。

デフォルト値: `true`

#### `service_ensure`

データタイプ: Enum['running'、'stopped']

NTPサービスを実行するかどうか指定します。

デフォルト値: 'running'


#### `service_manage`

データタイプ: 真偽値(boolean)

NTPサービスを管理するかどうか指定します。

デフォルト値: `true`

#### `service_name`

データタイプ: 文字列

管理対象のNTPサービス

デフォルト値: オペレーティングシステムによって異なります。

#### `service_provider`

データタイプ: 文字列

NTPに使用するサービスプロバイダ

デフォルト値: `undef`

#### `slewalways`

データタイプ: Enum['no'、'yes']

step動作を無効にし常にslewモードで徐々に時計を合わせるよう`xntpd`を設定するかどうかを指定します。

AIXといった`xntpd`を実行するプラットフォームにのみ適用し、その他のプラットフォームにこの設定を指定しないようにしてください。

デフォルト値: オペレーティングシステムによって異なります。 

#### `statistics`

データタイプ: 配列

ntpモニタリングが有効になっている場合に収集する統計のリスト

デフォルト値: []

#### `statsdir`

データタイプ: Stdlib::Absolutepath.

NTP統計の保存先(ntpモニタリングが有効になっている場合)

デフォルト値: '/var/log/ntpstats'

#### `step_tickers_file`

任意

データタイプ: Stdlib::Absolutepath.

管理対象システム上のstep tickersファイルの保存場所

デフォルト値: オペレーティングシステムによって異なります。


#### `step_tickers_epp`

任意

データタイプ: 文字列

step tickers EPPテンプレートファイルの保存場所。このパラメータと`step_tickers_template`パラメータの両方を指定すると、バリデーションエラーが発生します。

デフォルト値: オペレーティングシステムによって異なります。

#### `step_tickers_template`

任意

データタイプ: 文字列

step tickers ERBテンプレートファイルの保存場所。 このパラメータと`step_tickers_epp`パラメータの両方を指定すると、バリデーションエラーが発生します。

デフォルト値: オペレーティングシステムによって異なります。

#### `stepout`

任意

データタイプ: 整数[0, 65535]

`tinker`値が`true`の場合のstepoutの値。有効なオプション: unsigned shortint digit

デフォルト値: `undef`

#### `tos`

データタイプ: 真偽値(boolean)

tosオプションを有効にするかどうかを指定します。

デフォルト値: `false`

#### `tos_maxclock`

任意

データタイプ: 整数[1]

maxclock tosオプションを指定します。

デフォルト値: 6。

#### `tos_minclock`

任意

データタイプ: 整数[1]

minclock tosオプションを指定します。

デフォルト値: 3

#### `tos_minsane`

任意

データタイプ: 整数[1]

minsane tosオプションを指定します。

デフォルト値: 1

#### `tos_floor`

任意

データタイプ: 整数[1]

floor tosオプションを指定します。

デフォルト値: 1

#### `tos_ceiling`

任意

データタイプ: 整数[1]

ceiling tosオプションを指定します。

デフォルト値: 15

#### `tos_cohort`


データタイプ: 真偽値(boolean)、整数[0,1]

cohort tosオプションを指定します。有効なオプション: 0または1

デフォルト値: 0

#### `tinker`

データタイプ: 真偽値(boolean)

tinkerオプションを有効にするかどうかを指定します。

デフォルト値: `false`

#### `udlc`

データタイプ: 真偽値(boolean)

Undisciplined Local Clockを時刻ソースとして使用するようNTPを設定するかどうか指定します。
デフォルト値: `false`

#### `udlc_stratum`

任意。データタイプ: 整数[1,15]

Undisciplined Local Clockを時刻ソースとして使用する場合にサーバを実行する階層を指定します。ntpdが外部アクセス可能なネットワークに接続する場合は、この値を10以上にする必要があります。

デフォルト値: 10

## 制限事項

このモジュールは[PE対応のすべてのプラットフォーム](https://forge.puppetlabs.com/supported#compat-matrix)上でテスト済みです。さらに、Solaris 10とFedora 20-22上でもテスト済み(ただし非対応)です。

## 開発

Puppet Forge上のPuppetモジュールは公開プロジェクトです。このモジュールの今後の進展にはコミュニティによる協力が不可欠です。変更にご協力いただける場合はガイドラインに従ってください。

詳しくは[モジュールへの貢献に関するガイド](https://docs.puppetlabs.com/forge/contributing.html)をご覧ください。

### 貢献者

すでにご協力いただいている方のリストについては、[貢献者リスト](https://github.com/puppetlabs/puppetlabs-ntp/graphs/contributors)をご覧ください。