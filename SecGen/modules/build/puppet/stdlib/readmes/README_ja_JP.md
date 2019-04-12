# stdlib

#### 目次

1. [モジュールの説明 - モジュールの機能とその有益性](#モジュールの説明)
1. [セットアップ - stdlib導入の基本](#セットアップ)
1. [使用 - 設定オプションと追加機能](#使用)
1. [リファレンス - モジュールの機能と動作について](#リファレンス)
    1. [クラス](#クラス)
    1. [定義タイプ](#定義タイプ)
    1. [データタイプ](#データタイプ)
    1. [Facts](#facts)
    1. [関数](#関数)
1. [制約 - OS互換性など](#制約)
1. [開発 - モジュール貢献についてのガイド](#開発)
1. [コントリビュータ](#コントリビュータ)


## モジュールの説明

このモジュールでは、Puppetモジュールのリソースの 標準ライブラリを提供しています。Puppetモジュールでは、この標準ライブラリを広く使用しています。stdlibモジュールは、以下のリソースをPuppetに追加します。

 * ステージ
 * Facts
 * 関数
 * 定義タイプ
 * データタイプ
 * プロバイダ

> *注:* バージョン3.7のPuppet Enterpriseには、stdlibモジュールが含まれていません。Puppet Enterpriseを使用している場合は、Puppetと互換性のあるstdlibの最新リリースをインストールする必要があります。

## セットアップ

stdlibモジュールを[インストール](https://docs.puppet.com/puppet/latest/modules_installing.html)し、この標準ライブラリの関数、Facts、リソースをPuppetに追加します。

stdlibに依存するモジュールを記述する場合は、必ずmetadata.jsonで[依存関係を特定](https://docs.puppet.com/puppet/latest/modules_metadata.html#specifying-dependencies)してください。

## 使用

stdlibのほとんどの機能は、Puppetに自動的にロードされます。Puppetで標準化されたランステージを使用するには、`include stdlib`を用いてマニフェスト内でこのクラスを宣言してください。

宣言すると、stdlibがモジュール内の他のすべてのクラスを宣言します。現在モジュールに含まれている他のクラスは、`stdlib::stages`のみです。

`stdlib::stages`クラスは、インフラストラクチャ、言語ランタイム、アプリケーションレイヤの配備に関する各種のランステージを宣言します。ハイレベルステージは、以下のとおりです(順番どおり)。

  * setup
  * main
  * runtime
  * setup_infra
  * deploy_infra
  * setup_app
  * deploy_app
  * deploy

使用例:

```puppet
node default {
  include stdlib
  class { java: stage => 'runtime' }
}
```

## リファレンス

* [パブリッククラス][]
* [プライベートクラス][]
* [定義タイプ][]
* [データタイプ][]
* [Facts][]
* [関数][]

### クラス

#### パブリッククラス

`stdlib`クラスにはパラメータはありません。

#### プライベートクラス

* `stdlib::stages`: Puppetのランステージの標準セットを管理します。

### 定義タイプ

#### `file_line`

任意の行がファイル内に確実に含まれるようにします。最初と最後の空白を含め、行全体をマッチさせます。その行が与えられたファイルに含まれない場合は、Puppetがファイルの最後にその行を追加し、望ましい状態を確保します。1つのファイル内で複数のリソースを宣言し、複数の行を管理することが可能です。

例:

```puppet
file_line { 'sudo_rule':
  path => '/etc/sudoers',
  line => '%sudo ALL=(ALL) ALL',
}

file_line { 'sudo_rule_nopw':
  path => '/etc/sudoers',
  line => '%sudonopw ALL=(ALL) NOPASSWD: ALL',
}
```

上の例では、指定された両方の行が、ファイル `/etc/sudoers`に確実に含まれます。

マッチ例:

```puppet
file_line { 'bashrc_proxy':
  ensure => present,
  path   => '/etc/bashrc',
  line   => 'export HTTP_PROXY=http://squid.puppetlabs.vm:3128',
  match  => '^export\ HTTP_PROXY\=',
}
```

上の例では、`match`により、'export'で始まり'HTTP_PROXY'と続く行が探され、その行が行内の値に置き換えられます。

 `ensure => absent`を用いたマッチ例:

```puppet
file_line { 'bashrc_proxy':
  ensure            => absent,
  path              => '/etc/bashrc',
  line              => 'export HTTP_PROXY=http://squid.puppetlabs.vm:3128',
  match             => '^export\ HTTP_PROXY\=',
  match_for_absence => true,
}
```

上の例では、`match`により、'export'で始まり'HTTP_PROXY'と続く行が探され、その行が削除されます。複数の行がマッチし、`multiple => true`パラメータが設定されていない場合は、エラーが生じます。

エンコード例:

```puppet
file_line { "XScreenSaver":
  ensure   => present,
  path     => '/root/XScreenSaver'
  line     => "*lock: 10:00:00",
  match    => '^*lock:',
  encoding => "iso-8859-1",
}
```

ファイルにUTF-8に対応しない特殊文字が用いられていると、「Invalid byte sequence in UTF-8」(UTF-8で無効なバイト列)というエラーメッセージが表示されます。この場合は、ファイルエンコーディングを決定し、`encoding`属性で指定してください。

**Autorequire:** Puppetが管理しているファイルに、管理対象となる行が含まれている場合は、`file_line`リソースと当該ファイルの暗黙的な依存関係が設定されます。

##### パラメータ

パラメータは、別途説明がない限り、すべてオプションです。

* `after`

  このパラメータで指定された行の後に、Puppetが正規表現を用いて新規の行を追加します(既存の行が規定の位置に追加されます)。

  値: 正規表現を含む文字列
  
  デフォルト値: `undef`
  
* `encoding`
  
  適正なファイルエンコードを指定します。

  値: 有効なRuby文字エンコードを指定する文字列
  
  デフォルト: 'UTF-8'

* `ensure`: リソースが存在するかどうかを指定します。

  値: 'present'、'absent'
  
  デフォルト値: 'present'
  
* `line`

  **必須**
  
  `path`パラメータにより位置を示されたファイルに追加する行を設定します。
    
  値: 文字列
  
* `match`

  ファイル内の既存の行と比較する正規表現を指定します。マッチが見つかった場合、新規の行を追加するかわりに、置き換えられます。正規表現の比較は行の値に照らして行われ、マッチしない場合は、例外が発生します。
  
  値: 正規表現を含む文字列
  
  デフォルト値: `undef`
  

* `match_for_absence`

  `ensure => absent`の場合にマッチを適用するかどうかを指定します。`true`に設定してマッチを設定すると、マッチする行が削除されます。`false`に設定すると(デフォルト)、`ensure => absent`の場合にマッチが無視され、代わりに`line`の値が使用されます。`ensure => present`になっている場合は、このパラメータは無視されます。
  
  ブーリアン
  
  デフォルト値: `false`
  
* `multiple`

  `match`および`after`により複数の行を変更できるかどうかを指定します。`false`に設定すると、複数の行がマッチする場合に例外が発生します。
  
  値: `true`、`false`
  
  デフォルト値: `false`
  
  
* `name`

  リソースの名称として使用する名前を指定します。リソースのnamevarをリソースの規定の`title`と異なるものにしたい場合は、`name`で名前を指定します。 
  
  値: 文字列
  
  デフォルト値: タイトルの値
  
* `path`

  **必須**
  
  `line`で指定された行を確保するファイルを指定します。 
  
  値: 当該ファイルの絶対パスを指定する文字列
  
* `replace`

  `match`パラメータとマッチする既存の行を上書きするかどうかを指定します。`false`に設定すると、`match`パラメータにマッチする行が見つかった場合、その行はファイルに配置されません。
  
  ブーリアン
  
  デフォルト値: `true`

### データタイプ

#### `Stdlib::Absolutepath`

厳密な絶対パスタイプ。UnixpathタイプおよびWindowspathタイプの異形を使用します。

使用可能なインプット例:

```shell
/var/log
```

```shell
/usr2/username/bin:/usr/local/bin:/usr/bin:.
```

```shell
C:\\WINDOWS\\System32
```

使用不可能なインプット例:

```shell
../relative_path
```

#### `Stdlib::Httpsurl`

HTTPS URLに一致します。

使用可能なインプット例:

```shell
https://hello.com
```

使用不可能なインプット例:

```shell
httds://notquiteright.org`
```

#### `Stdlib::Httpurl`

HTTPSおよびHTTP URLの両方に一致します。

使用可能なインプット例:

```shell
https://hello.com

http://hello.com
```

使用不可能なインプット例:

```shell
httds://notquiteright.org
```

#### `Stdlib::Unixpath`

Unixオペレーティングシステムのパスに一致します。

使用可能なインプット例:

```shell
/usr2/username/bin:/usr/local/bin:/usr/bin:

/var/tmp
```

使用不可能なインプット例:

```shell
C:/whatever
```

#### `Stdlib::Windowspath`

Windowsオペレーティングシステムのパスに一致します。

使用可能なインプット例: 

```shell
C:\\WINDOWS\\System32

C:\\

\\\\host\\windows
```

使用不可能なインプット例:

```shell
/usr2/username/bin:/usr/local/bin:/usr/bin:.
```

### Facts

#### `package_provider`

Puppetがこのシステムのパッケージ管理に使用するデフォルトのプロバイダを返します。

#### `is_pe`

Puppet Enterpriseがインストールされているかどうかを返します。PE 3.x以降のプラットフォームでは何も報告されません。

#### `pe_version`

インストールされているPuppet Enterpriseのバージョンを返します。PE 3.x以降のプラットフォームでは何も報告されません。

#### `pe_major_version`

インストールされているPuppet Enterpriseのメジャーバージョンを返します。PE 3.x以降のプラットフォームでは何も報告されません。

#### `pe_minor_version`

インストールされているPuppet Enterpriseのマイナーバージョンを返します。PE 3.x以降のプラットフォームでは何も報告されません。

#### `pe_patch_version`

インストールされているPuppet Enterpriseのパッチバージョンを返します。

#### `puppet_vardir`

PuppetまたはPuppet agentが稼働しているノードについて設定されたPuppet vardirの値を返します。

#### `puppet_environmentpath`

PuppetまたはPuppet agentが稼働しているノードについて設定されたPuppet環境の値を返します。

#### `puppet_server`

Puppet agentの`server`値を返します。この値は、agentが通信するPuppet masterのホストネームです。

#### `root_home`

ルートのホームディレクトリを決定します。

ルートのホームディレクトリを決定します。これは、オペレーティングシステムによって異なります。通常は'/root'です。

#### `service_provider`

Puppetがこのシステムのサービス管理に使用するデフォルトのプロバイダを返します。

### 関数

#### `abs`

数字の絶対値を返します。たとえば、'-34.56'は'34.56'になります。

引数: 整数値または浮動小数点値のいずれかの単一の引数。

*タイプ*: 右辺値

#### `any2array`

任意のオブジェクトを、そのオブジェクトを含む配列に変換します。空の引数リストは空の配列に変換されます。ハッシュは、キーと値が交互になった配列に変換されます。配列は変換されません。

*タイプ*: 右辺値

#### `any2bool`

任意のオブジェクトをブーリアンに変換します。

* 'Y'、'y'、'1'、'T'、't'、'TRUE'、'yes'、'true'といった文字列は`true`を返します。
* '0'、'F'、'f'、'N'、'n'、'FALSE'、'no'、'false'といった文字列は`false`を返します。
* ブーリアンは元の値を返します。
* 0よりも大きい数字(または数字の文字列表現)は`true`を返します。それ以外は`false`を返します。
* undef値は`false`を返します。
* それ以外はすべて`true`を返します。

*タイプ*: 右辺値

#### `assert_private`

現在のクラスまたは定義をプライベートとして設定します。現在のモジュール外のクラスまたは定義タイプを呼び出すことはできません。

たとえば、クラス`foo::bar`で`assert_private()`がコールされると、クラスがモジュール`foo`の外から呼び出された場合、次のメッセージがアウトプットされます：`Class foo::bar is private`。

使用したいエラーメッセージを指定する方法:

```puppet
assert_private("You're not supposed to do that!")
```

*タイプ*: ステートメント

#### `base64`

文字列とbase64エンコードを相互に変換します。`action` ('encode'、'decode')とプレーンまたは base64でエンコードした`string`、およびオプションで`method` ('default'、'strict'、'urlsafe')が必要です。

下位互換性を得るには、`method`を`default`に設定します(指定されていない場合)。

*注:* この関数はRubyクラスの実装にあたり、UTF8との互換性がない可能性があります。互換性を確保するには、Ruby 2.4.0以降でこの関数を使用してください。

**例:**

```puppet
base64('encode', 'hello')
base64('encode', 'hello', 'default')
# リターン: "aGVsbG8=\n"

base64('encode', 'hello', 'strict')
# リターン: "aGVsbG8="

base64('decode', 'aGVsbG8=')
base64('decode', 'aGVsbG8=\n')
base64('decode', 'aGVsbG8=', 'default')
base64('decode', 'aGVsbG8=\n', 'default')
base64('decode', 'aGVsbG8=', 'strict')
# リターン: "hello"

base64('encode', 'https://puppetlabs.com', 'urlsafe')
# リターン: "aHR0cHM6Ly9wdXBwZXRsYWJzLmNvbQ=="

base64('decode', 'aHR0cHM6Ly9wdXBwZXRsYWJzLmNvbQ==', 'urlsafe')
# リターン: "https://puppetlabs.com"
```

*タイプ*: 右辺値

#### `basename`

パスの`basename`を返します。オプションの引数で拡張子が外れます。例:

  * ('/path/to/a/file.ext')は'file.ext'を返します。
  * ('relative/path/file.ext')は'file.ext'を返します。
  * ('/path/to/a/file.ext', '.ext')は'file'を返します。

*タイプ*: 右辺値

#### `bool2num`

ブーリアンを数字に変換します。以下の値を変換します。

* `false`、'f'、'0'、'n'、'no'を0に変換します。
* `true`、't'、'1'、'y'、'yes'を1に変換します。
  
  引数: インプットとして、単一のブーリアンまたは文字列。
  
  *タイプ*: 右辺値

#### `bool2str`

オプションで提供される引数を用いて、ブーリアンを文字列に変換します。オプションの第2および第3の引数は、trueおよびfalseがそれぞれ何に変換されるかを表しています。与えられた引数が1つだけの場合は、ブーリアンから`true`または`false`を含む文字列に変換されます。

*例:*

```puppet
bool2str(true)                    => `true`
bool2str(true, 'yes', 'no')       => 'yes'
bool2str(false, 't', 'f')         => 'f'
```

引数: ブーリアン。

*タイプ*: 右辺値

#### `camelcase`

配列内の1つの文字列またはすべての文字列の大文字と小文字の別をCamelCase(大小文字混在)に変換します。

引数: 配列または文字列のいずれか。受け取ったものと同じタイプの引数を返しますが、CamelCaseの形式で返します。

*注:* この関数はRubyクラスの実装にあたり、UTF8との互換性がない可能性があります。互換性を確保するには、Ruby 2.4.0以降でこの関数を使用してください。

 *タイプ*: 右辺値

#### `capitalize`

文字列または複数文字列の配列の最初の文字を大文字にし、各文字列の残りの文字を小文字にします。

引数: インプットとして、単一文字列または配列。*タイプ*: 右辺値

*注:* この関数はRubyクラスの実装にあたり、UTF8との互換性がない可能性があります。互換性を確保するには、Ruby 2.4.0以降でこの関数を使用してください。

#### `ceiling`

引数以上の最小整数を返します。

引数: 単一の数値。

*タイプ*: 右辺値

#### `chomp`

文字列または複数文字列の配列の最後から、レコード分離文字を削除します。たとえば、'hello\n'は'hello'になります。

引数: 単一の文字または配列。

*タイプ*: 右辺値

#### `chop`

最後の文字を削除した新しい文字列を返します。文字列が'\r\n'で終わる場合は、両方の文字が削除されます。`chop`を空文字列に適用すると、空文字列が返されます。レコード分離文字のみを削除する場合は、`chomp`関数を使用してください。

引数: インプットとして、文字列または複数文字列の配列。

*タイプ*: 右辺値

#### `clamp`

整数値に基づく分類により、当該領域[Min、X、Max]内で値を維持します(パラメータの順序は関係ありません)。文字列が変換され、数字として比較されます。値の配列は、さらなる処理が可能なリストに平坦化されます。例:

  * `clamp('24', [575, 187])`は187を返します。
  * `clamp(16, 88, 661)`は88を返します。
  * `clamp([4, 3, '99'])`は4を返します。
  
引数: 文字列、配列、数字。 

*タイプ*: 右辺値

#### `concat`

複数配列のコンテンツを、与えられた最初の配列に追加します。例:

  * `concat(['1','2','3'],'4')`は['1','2','3','4']を返します。
  * `concat(['1','2','3'],'4',['5','6','7'])`は['1','2','3','4','5','6','7']を返します。

*タイプ*: 右辺値

#### `convert_base`

与えられた整数または整数を表す10進数文字列を、指定した基数の文字列に変換します。例:

  * `convert_base(5, 2)`は'101'になります。
  * `convert_base('254', '16')`は'fe'になります。

#### `count`

配列のみで呼び出した場合は、空または`undef`**ではない**要素の数をカウントします。第2の引数を用いて呼び出した場合は、第2の引数にマッチする配列内の要素の数をカウントします。

*タイプ*: 右辺値

#### `deep_merge`

2つ以上のハッシュを再帰的に統合し、その結果得られたハッシュを返します。

```puppet
$hash1 = {'one' => 1, 'two' => 2, 'three' => { 'four' => 4 } }
$hash2 = {'two' => 'dos', 'three' => { 'five' => 5 } }
$merged_hash = deep_merge($hash1, $hash2)
```

得られるハッシュは、以下に相当します。

```puppet
$merged_hash = { 'one' => 1, 'two' => 'dos', 'three' => { 'four' => 4, 'five' => 5 } }
```

ハッシュである重複キーが存在する場合は、そうした重複キーが再帰的に統合されます。ハッシュではない重複キーが存在する場合は、最右のハッシュのキーが上位になります。

*タイプ*: 右辺値

#### `defined_with_params`

属性のリソースリファレンスとオプションでハッシュを取得します。特定の属性を持つリソースがすでにカタログに追加されている場合は`true`を返します。そうでない場合は`false`を返します。

```puppet
user { 'dan':
  ensure => present,
}

if ! defined_with_params(User[dan], {'ensure' => 'present' }) {
  user { 'dan': ensure => present, }
}
```

*タイプ*: 右辺値

#### `delete`

配列から任意の要素のインスタンスを、文字列からサブストリングを、またはハッシュからキーをすべて削除します。

例:

* `delete(['a','b','c','b'], 'b')`は['a','c']を返します。
* `delete('abracadabra', 'bra')`は'acada'を返します。
* `delete({'a' => 1,'b' => 2,'c' => 3},['b','c'])`は{'a'=> 1}を返します。
* `delete(['ab', 'b'], 'b')`は['ab']を返します。

*タイプ*: 右辺値

#### `delete_at`

決められたインデックス付き値を配列から削除します。

例: `delete_at(['a','b','c'], 1)`は['a','c']を返します。

*タイプ*: 右辺値

#### `delete_regex`

提示された正規表現にマッチする任意の要素のインスタンスを、配列またはハッシュからすべて削除します。文字列は1アイテム配列として処理されます。

*注:* この関数はRubyクラスの実装にあたり、UTF8との互換性がない可能性があります。互換性を確保するには、Ruby 2.4.0以降でこの関数を使用してください。


例

* `delete_regex(['a','b','c','b'], 'b')`は['a','c']を返します。
* `delete_regex({'a' => 1,'b' => 2,'c' => 3},['b','c'])`は{'a'=> 1}を返します。
* `delete_regex(['abf', 'ab', 'ac'], '^ab.*')`は['ac']を返します。
* `delete_regex(['ab', 'b'], 'b')`は['ab']を返します。

*タイプ*: 右辺値

#### `delete_values`

任意の値のインスタンスをハッシュからすべて削除します。

例:

* `delete_values({'a'=>'A','b'=>'B','c'=>'C','B'=>'D'}, 'B')`は{'a'=>'A','c'=>'C','B'=>'D'}を返します。

*タイプ*: 右辺値

#### `delete_undef_values`

`undef`値のインスタンスをアレイまたはハッシュからすべて削除します。

例:

* `$hash = delete_undef_values({a=>'A', b=>'', c=>`undef`, d => false})`は{a => 'A', b => '', d => false}を返します。

*タイプ*: 右辺値

#### `deprecation`

非推奨警告をプリントし、任意のキーについて警告を一度記録します:

```puppet
deprecation(key, message)
```

引数:

* キーを指定する文字列: Puppetプロセスの継続期間中にメッセージの数を少なく抑えるために、1つのキーにつき1つのメッセージのみを記録します。
* メッセージを指定する文字列: 記録されるテキスト。

*タイプ*: ステートメント

**`deprecation`に影響を与える設定**

Puppetの他の設定は、stdlibの`deprecation`関数に影響を与えます。

* [`disable_warnings`](https://docs.puppet.com/puppet/latest/reference/configuration.html#disablewarnings)
* [`max_deprecations`](https://docs.puppet.com/puppet/latest/reference/configuration.html#maxdeprecations)
* [`strict`](https://docs.puppet.com/puppet/latest/reference/configuration.html#strict):

    * `error`: 非推奨メッセージにより、ただちに機能しなくなります。
    * `off`: メッセージがアウトプットされません。
    * `warning`: すべての警告を記録します。これがデフォルト設定です。

* 環境変数`STDLIB_LOG_DEPRECATIONS`

  非推奨警告を記録するかどうかを指定します。これは特に、自動テストの際、移行の準備ができる前にログに情報が氾濫するのを避けるうえで役立ちます。

  この変数はブーリアンで、以下の効果があります:
  
  * `true`: 警告を記録します。
  * `false`: 警告は記録されません。
  * 値を設定しない場合: Puppet 4は警告を出しますが、Puppet 3は出しません。

#### `difference`

2つの配列の間の差異を返します。返される配列はオリジナル配列のコピーで、第2の配列にも見られるアイテムがあれば、それが取り除かれます。

例:

* `difference(["a","b","c"],["b","c","d"])`は["a"]を返します。

*タイプ*: 右辺値

#### `dig`

> 非推奨: この関数は、Puppet 4.5.0で、内蔵の[`dig`](https://docs.puppet.com/puppet/latest/function.html#dig)関数に置き換えられました。下位互換性を得るには、[`dig44()`](#dig44)を使用するか、新しいバージョンを使用してください。

パスを含むキー配列を通じて、複数レイヤーのハッシュおよびアレイ内の値を探します。この関数は各パスコンポーネントにより構造内を移動し、パスの最後で値を返すよう試みます。

この関数では、必要とされるパス引数に加え、デフォルトの引数を使用できます。パスが正しくない場合や、値が見つからない場合、その他のエラーが生じた場合は、デフォルトの引数を返します。

```ruby
$data = {
  'a' => {
    'b' => [
      'b1',
      'b2',
      'b3',
    ]
  }
}

$value = dig($data, ['a', 'b', 2])
# $value = 'b3'

# 可能なすべてのオプションを使用
$value = dig($data, ['a', 'b', 2], 'not_found')
# $value = 'b3'

# デフォルト値を使用
$value = dig($data, ['a', 'b', 'c', 'd'], 'not_found')
# $value = 'not_found'
```

1. **$data** 取り扱うデータ構造。
2. **['a', 'b', 2]** パス配列。
3. **'not_found'** デフォルト値。何も見つからない場合に返されます。

デフォルト値: `undef`

*タイプ*: 右辺値

#### `dig44`

パスを含むキー配列を通じて、複数レイヤーのハッシュおよびアレイ内の値を探します。この関数は各パスコンポーネントにより構造内を移動し、パスの最後で値を返すよう試みます。

この関数では、必要とされるパス引数に加え、デフォルトの引数を使用できます。パスが正しくない場合や、値が見つからない場合、その他のエラーが生じた場合は、デフォルトの引数を返します。

```ruby
$data = {
  'a' => {
    'b' => [
      'b1',
      'b2',
      'b3',
    ]
  }
}

$value = dig44($data, ['a', 'b', 2])
# $value = 'b3'

# 可能なすべてのオプションを使用
$value = dig44($data, ['a', 'b', 2], 'not_found')
# $value = 'b3'

# デフォルト値を使用
$value = dig44($data, ['a', 'b', 'c', 'd'], 'not_found')
# $value = 'not_found'
```

*タイプ*: 右辺値

1. **$data** 取り扱うデータ構造。
2. **['a', 'b', 2]** パス配列。
3. **'not_found'** デフォルト値。何も見つからない場合に返されます。
   (オプション、デフォルトは`undef`)

#### `dirname`

パスの`dirname`を返します。たとえば、`dirname('/path/to/a/file.ext')`は'/path/to/a'を返します。

*タイプ*: 右辺値

#### `dos2unix`

与えられた文字列のUnixバージョンを返します。クロスプラットフォームテンプレートでファイルリソースを使用する場合に非常に役立ちます。

```puppet
file{$config_file:
  ensure  => file,
  content => dos2unix(template('my_module/settings.conf.erb')),
}
```

[unix2dos](#unix2dos)も参照してください。

*タイプ*: 右辺値

#### `downcase`

配列内の1つの文字列またはすべての文字列の大文字と小文字の別を、小文字に変換します。

*注:* この関数はRubyクラスの実装にあたり、UTF8との互換性がない可能性があります。互換性を確保するには、Ruby 2.4.0以降でこの関数を使用してください。

*タイプ*: 右辺値

#### `empty`

引数が要素を含まない配列かハッシュ、または空文字列である場合に、`true`を返します。引数が数値の場合に`false`を返します。

*タイプ*: 右辺値

#### `enclose_ipv6`

IPアドレスの配列を取得し、ipv6アドレスを大括弧でくくります。

*タイプ*: 右辺値

#### `ensure_packages`

配列またはハッシュ内のパッケージのリストを取得し、すでに存在しない場合にのみ、それらをインストールします。オプションで、ハッシュを第2のパラメータとして取得し、第3の引数として`ensure_resource()`または `ensure_resources()`関数に渡します。

*タイプ*: ステートメント

配列の場合:

```puppet
ensure_packages(['ksh','openssl'], {'ensure' => 'present'})
```

ハッシュの場合:

```puppet
ensure_packages({'ksh' => { ensure => '20120801-1' } ,  'mypackage' => { source => '/tmp/myrpm-1.0.0.x86_64.rpm', provider => "rpm" }}, {'ensure' => 'present'})
```

#### `ensure_resource`

リソースタイプ、タイトル、リソースを記述する属性のハッシュを取得します。

```
user { 'dan':
  ensure => present,
}
```

この例では、すでに存在しない場合にのみリソースが作成されます:

  `ensure_resource('user', 'dan', {'ensure' => 'present' })`

リソースがすでに存在しているものの、指定されたパラメータとマッチしない場合は、リソースの再作成が試みられ、重複リソース定義エラーにつながります。

リソースの配列を提示することも可能です。それぞれのリソースは、すでに存在しない場合に、指定のタイプおよびパラメータにより作成されます。

`ensure_resource('user', ['dan','alex'], {'ensure' => 'present'})`

*タイプ*: ステートメント

#### `ensure_resources`

ハッシュからリソース宣言を作成しますが、すでに宣言されているリソースとは対立しません。

リソースタイプ、タイトル、リソースを記述する属性のハッシュを指定します。

```puppet
user { 'dan':
  gid => 'mygroup',
  ensure => present,
}

ensure_resources($user)
```

リソースのハッシュを提示します。リストにあるリソースは、すでに存在しない場合に、指定のタイプおよびパラメータにより作成されます。

    ensure_resources('user', {'dan' => { gid => 'mygroup', uid => '600' } ,  'alex' => { gid => 'mygroup' }}, {'ensure' => 'present'})

Hieraバックエンドから:

```yaml
userlist:
  dan:
    gid: 'mygroup'
    uid: '600'
  alex:
    gid: 'mygroup'
```

```puppet
ensure_resources('user', hiera_hash('userlist'), {'ensure' => 'present'})
```

### `flatten`

ネストの深いアレイを平坦化し、結果として単一のフラット配列を返します。

たとえば、`flatten(['a', ['b', ['c']]])`は['a','b','c']を返します。

*タイプ*: 右辺値

#### `floor`

引数以下の最大整数を返します。

引数: 単一の数値。

*タイプ*: 右辺値

#### `fqdn_rand_string`

ランダムな英数字文字列を生成します。`$fqdn` factとオプションのシードを組み合わせると、反復的な無作為抽出が可能です。オプションで、この関数に使用する文字セットを指定することもできます(デフォルトは英数字)。

*使用例:*

```puppet
fqdn_rand_string(LENGTH, [CHARSET], [SEED])
```

*例:*

```puppet
fqdn_rand_string(10)
fqdn_rand_string(10, 'ABCDEF!@#$%^')
fqdn_rand_string(10, '', 'custom seed')
```

引数:

* 整数、得られる文字列の長さを指定。
* オプションで、文字セットを指定する文字列。
* オプションで、反復的な無作為抽出を可能にするシードを指定する文字列。

*タイプ*: 右辺値

#### `fqdn_rotate`

配列と文字列をランダムな回数で回転させます。`$fqdn` factとオプションのシードを組み合わせると、反復的な無作為抽出が可能です。

*使用例:*

```puppet
fqdn_rotate(VALUE, [SEED])
```

*例:*

```puppet
fqdn_rotate(['a', 'b', 'c', 'd'])
fqdn_rotate('abcd')
fqdn_rotate([1, 2, 3], 'custom seed')
```

*タイプ*: 右辺値

#### `fqdn_uuid`

DNSネームスペースのFQDN文字列をもとに、[RFC 4122](https://tools.ietf.org/html/rfc4122)有効バージョン5 UUIDを返します:

  * fqdn_uuid('puppetlabs.com')は'9c70320f-6815-5fc5-ab0f-debe68bf764c'を返します。
  * fqdn_uuid('google.com')は'64ee70a4-8cc1-5d25-abf2-dea6c79a09c8'を返します。

*タイプ*: 右辺値

#### `get_module_path`

現在の環境について、指定されたモジュールの絶対パスを返します。

```puppet
$module_path = get_module_path('stdlib')
```

*タイプ*: 右辺値

#### `getparam`

リソースのパラメータの値を返します。

引数: リソースリファレンスおよびパラメータの名前。

たとえば、以下の場合は'param_value'を返します:

```puppet
define example_resource($param) {
}

example_resource { "example_resource_instance":
  param => "param_value"
}

getparam(Example_resource["example_resource_instance"], "param")
```

*タイプ*: 右辺値

#### `getvar`

リモートネームスペースの変数を調べます。

例:

```puppet
$foo = getvar('site::data::foo')
# $foo = $site::data::fooに相当
```

この関数は、ネームスペースそのものが文字列に保存されている場合に役立ちます:

```puppet
$datalocation = 'site::data'
$bar = getvar("${datalocation}::bar")
# $bar = $site::data::barに相当
```

*タイプ*: 右辺値

#### `glob`

パスパターンに一致するパスの文字列配列を返します。

引数: パスパターンを指定する文字列または文字列配列。

```puppet
$confs = glob(['/etc/**/*.conf', '/opt/**/*.conf'])
```

*タイプ*: 右辺値

#### `grep`

配列内を検索し、提示された正規表現に一致する要素を返します。

たとえば、`grep(['aaa','bbb','ccc','aaaddd'], 'aaa')`は['aaa','aaaddd']を返します。

*タイプ*: 右辺値

#### `has_interface_with`

種類および値に基づきブーリアンを返します:

  * macaddress
  * netmask
  * ipaddress
  * network

*例:*

```puppet
has_interface_with("macaddress", "x:x:x:x:x:x")
has_interface_with("ipaddress", "127.0.0.1")    => true
```

種類が提示されていない場合は、インターフェースの有無が確認されます:

```puppet
has_interface_with("lo")                        => true
```

*タイプ*: 右辺値

#### `has_ip_address`

一部のインターフェース上で、リクエストされたIPアドレスがクライアントに存在する場合は`true`を返します。この関数は`interfaces` factで反復され、`ipaddress_IFACE` factsをチェックし、簡単な文字列比較を実行します。

引数: IPアドレスを指定する文字列。

*タイプ*: 右辺値

#### `has_ip_network`

リクエストされたネットワーク内でIPアドレスがクライアントに存在する場合は`true`を返します。この関数は`interfaces` factで反復され、 `network_IFACE` factsをチェックし、簡単な文字列比較を実行します。

引数: IPアドレスを指定する文字列。

*タイプ*: 右辺値

#### `has_key`

ハッシュに特定のキー値があるかどうかを判定します。

*例*:

```
$my_hash = {'key_one' => 'value_one'}
if has_key($my_hash, 'key_two') {
  notice('we will not reach here')
}
if has_key($my_hash, 'key_one') {
  notice('this will be printed')
}
```

*タイプ*: 右辺値

#### `hash`

配列をハッシュに変換します。

たとえば、`hash(['a',1,'b',2,'c',3])`は{'a'=>1,'b'=>2,'c'=>3}を返します。

*タイプ*: 右辺値

#### `intersection`

2つの共通部分の配列を返します。

たとえば、`intersection(["a","b","c"],["b","c","d"])`は["b","c"]を返します。

*タイプ*: 右辺値

#### `is_a`

ブーリアンチェックにより、変数が任意のデータタイプのものかどうかを判定します。これは`=~`タイプチェックに相当します。この関数はPuppet 4と、"future"パーサーを備えたPuppet 3でのみ使用できます。

```
foo = 3
$bar = [1,2,3]
$baz = 'A string!'

if $foo.is_a(Integer) {
  notify  { 'foo!': }
}
if $bar.is_a(Array) {
  notify { 'bar!': }
}
if $baz.is_a(String) {
  notify { 'baz!': }
}
```

* タイプに関する詳細は、[Puppetタイプシステム](https://docs.puppetlabs.com/latest/type.html#about-resource-types)を参照してください。
* 値のタイプを特定する各種の方法については、[`assert_type()`](https://docs.puppetlabs.com/latest/function.html#asserttype)関数を参照してください。

#### `is_absolute_path`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

与えられたパスが絶対パスである場合に`true`を返します。

*タイプ*: 右辺値

#### `is_array`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

この関数に渡された変数が配列である場合に`true`を返します。

*タイプ*: 右辺値

#### `is_bool`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

この関数に渡された変数がブーリアンである場合に`true`を返します。

*タイプ*: 右辺値

#### `is_domain_name`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

この関数に渡された文字列が構文的に正しいドメイン名である場合に`true`を返します。

*タイプ*: 右辺値

#### `is_float`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

この関数に渡された変数がフロート型である場合に`true`を返します。

*タイプ*: 右辺値

#### `is_function_available`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

文字列を引数として受け入れ、Puppetランタイムがその名前を用いて関数にアクセスできるかどうかを判定します。関数が存在する場合は`true`、存在しない場合は`false`を返します。

*タイプ*: 右辺値

#### `is_hash`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

この関数に渡された変数がハッシュである場合に`true`を返します。

*タイプ*: 右辺値

#### `is_integer`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

この文字列に返された変数が整数である場合に`true`を返します。

*タイプ*: 右辺値

#### `is_ip_address`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

この関数に渡された文字列が有効なIPアドレスである場合に`true`を返します。

*タイプ*: 右辺値

#### `is_ipv6_address`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

この関数に渡された文字列が有効なIPv6アドレスである場合に`true`を返します。

*タイプ*: 右辺値

#### `is_ipv4_address`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

この関数に渡された文字列が有効なIPv4アドレスである場合に`true`を返します。

*タイプ*: 右辺値

#### `is_mac_address`

この関数に渡された文字列が有効なMACアドレスである場合に`true`を返します。

*タイプ*: 右辺値

#### `is_numeric`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

この関数に渡された変数が数字である場合に`true`を返します。

*タイプ*: 右辺値

#### `is_string`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

この関数に渡された変数が文字列である場合に`true`を返します。

*タイプ*: 右辺値

#### `join`

区切り文字を用いて、配列を文字列に結合します。たとえば、`join(['a','b','c'], ",")`は"a,b,c"になります。

*タイプ*: 右辺値

#### `join_keys_to_values`

区切り文字を用いて、ハッシュの各キーをそのキーに対応する値と結合し、結果を文字列として返します。 

値が配列の場合は、キーは各要素の前に置かれます。返される値は、平坦化した配列になります。

たとえば、`join_keys_to_values({'a'=>1,'b'=>[2,3]}, " is ")`は["a is 1","b is 2","b is 3"]になります。

*タイプ*: 右辺値

#### `keys`

ハッシュのキーを配列として返します。

*タイプ*: 右辺値

#### `length`

与えられた文字列、配列、ハッシュの長さを返します。廃止された`size()`関数に代わるものです。

*タイプ*: 右辺値

#### `loadyaml`

配列、文字列、ハッシュを含むYAMLファイルをロードし、対応するネイティブデータタイプでデータを返します。

例:

```puppet
$myhash = loadyaml('/etc/puppet/data/myhash.yaml')
```

第2のパラメータは、ファイルが見つからなかった場合、または構文解析できなかった場合に返されます。

例:

```puppet
$myhash = loadyaml('no-file.yaml', {'default'=>'value'})
```

*タイプ*: 右辺値

#### `loadjson`

配列、文字列、ハッシュを含むJSONファイルをロードし、対応するネイティブデータタイプでデータを返します。

例:

```puppet
$myhash = loadjson('/etc/puppet/data/myhash.json')
```

第2のパラメータは、ファイルが見つからなかった場合、または構文解析できなかった場合に返されます。

例:

```puppet
  $myhash = loadjson('no-file.json', {'default'=>'value'})
  ```

*タイプ*: 右辺値

#### `load_module_metadata`

ターゲットモジュールのmetadata.jsonをロードします。モジュールのバージョンや、モジュールの動的サポートに関するオーサーシップの判定に使用できます。

```puppet
$metadata = load_module_metadata('archive')
notify { $metadata['author']: }
```

モジュールのメタデータファイルが存在しない場合、カタログコンパイルに失敗します。これを避ける方法は、以下のとおりです:

```
$metadata = load_module_metadata('mysql', true)
if empty($metadata) {
  notify { "This module does not have a metadata.json file.": }
}
```

*タイプ*: 右辺値

#### `lstrip`

文字列の左側のスペースを取り除きます。

*タイプ*: 右辺値

#### `max`

すべての引数の最大値を返します。少なくとも1つの引数が必要です。

引数: 数字または数字を表す文字列。

*タイプ*: 右辺値

#### `member`

変数が配列の構成要素かどうかを判定します。変数には文字列、配列、fixnumが使用できます。

たとえば、`member(['a','b'], 'b')`および`member(['a','b','c'], ['b','c'])`は`true`を返し、`member(['a','b'], 'c')`および`member(['a','b','c'], ['c','d'])`は`false`を返します。

*注*: この関数は、ネスト化した配列には対応していません。最初の引数にネスト化した配列が含まれている場合は、再帰的処理は行われません。

*タイプ*: 右辺値

#### `merge`

2つ以上のハッシュを統合し、その結果得られたハッシュを返します。

*例*:

```puppet
$hash1 = {'one' => 1, 'two' => 2}
$hash2 = {'two' => 'dos', 'three' => 'tres'}
$merged_hash = merge($hash1, $hash2)
# 得られるハッシュは、以下に相当します:
# $merged_hash =  {'one' => 1, 'two' => 'dos', 'three' => 'tres'}
```

重複キーが存在する場合は、最右のハッシュのキーが上位になります。

*タイプ*: 右辺値

#### `min`

すべての引数の最小値を返します。少なくとも1つの引数が必要です。

引数: 数字または数字を表す文字列。

*タイプ*: 右辺値

#### `num2bool`

数字または数字の文字列表現を正当なブーリアンに変換します。0または非数字は`false`になります。0より大きい数字は`true`になります。

*タイプ*: 右辺値

#### `parsejson`

JSONの文字列を正確なPuppet構造に変換します(ハッシュ、配列、文字列、整数、またはそれらの組み合わせとして)。

引数:
* 第1の引数として、変換されるJSON文字列。
* オプションで、第2のエラーとして、変換に失敗した場合に返される結果。

*タイプ*: 右辺値

#### `parseyaml`

YAMLの文字列を正確なPuppet構造に変換します。

引数:
* 第1の引数として、変換されるYAML文字列。
* オプションで、第2のエラーとして、変換に失敗した場合に返される結果。

*タイプ*: 右辺値 

#### `pick`

値のリストから、未定義または空文字列ではない最初の値を返します。引数から任意の数字をとり、すべての値が未定義または空の場合はエラーが生じます。

```puppet
$real_jenkins_version = pick($::jenkins_version, '1.449')
```

*タイプ*: 右辺値

#### `pick_default`

値のリストにある最初の値を返します。`pick()`関数とは異なり、`pick_default()`は、すべての引数が空の場合も失敗にはなりません。そのため、デフォルトとして空の値を使用できます。

*タイプ*: 右辺値

#### `prefix`

配列のすべての要素、またはハッシュのキーに接頭辞を適用します。

例:

* `prefix(['a','b','c'], 'p')`は['pa','pb','pc']を返します。
* `prefix({'a'=>'b','b'=>'c','c'=>'d'}, 'p')`は{'pa'=>'b','pb'=>'c','pc'=>'d'}を返します。

*タイプ*: 右辺値

#### `pry`

現在のスコープオブジェクトでpryデバッグセッションを起動します。コンパイル中の特定ポイントにおけるマニフェストコードのデバッグに役立ちます。`puppet apply`の実行中またはフォアグラウンドでPuppet masterを実行しているときにのみ使用する必要があります。PuppetのRubyGemsに`pry` gemがインストールされている必要があります。

*例:*

```puppet
pry()
```

pryセッションで役立つコマンドは以下のとおりです:

* `catalog`を実行すると、現在カタログをコンパイルしているコンテンツを見られます。
* `cd catalog`および`ls`を実行すると、カタログメソッドおよびインスタンス変数を見られます。
* `@resource_table`を実行すると、現在のカタログリソーステーブルを見られます。

#### `pw_hash`

crypt関数を用いてパスワードをハッシュします。ほとんどのPOSIXシステムで使えるハッシュを提供します。

この関数の最初の引数は、ハッシュするパスワードです。`undef`または空文字列の場合は、この関数により`undef`が返されます。

この関数の第2の引数は、使用するハッシュのタイプです。適切なcrypt(3)ハッシュ指定子に変換されます。有効なハッシュタイプは以下のとおりです:

|ハッシュタイプ            |指定子|
|---------------------|---------|
|MD5                  |1        |
|SHA-256              |5        |
|SHA-512 (推奨)|6        |

この関数の第3の引数は、使用するソルトです。

この関数は、Puppet masterのcrypt(3)実装を使用しています。お使いの環境に複数の異なるオペレーティングシステムが含まれている場合は、この関数を使用する前に、互換性があることを確認してください。

*タイプ*: 右辺値

*注:* この関数はRubyクラスの実装にあたり、UTF8との互換性がない可能性があります。互換性を確保するには、Ruby 2.4.0以降でこの関数を使用してください。

#### `range`

'(start, stop)'の形式で与えられた場合に、領域を配列として外挿します。たとえば、`range("0", "9")`は[0,1,2,3,4,5,6,7,8,9]を返します。ゼロパディングされた文字列は、自動的に整数に変換されます。したがって、`range("00", "09")`は[0,1,2,3,4,5,6,7,8,9]を返します。

非整数文字列を使用できます:

* `range("a", "c")`は["a","b","c"]を返します。
* `range("host01", "host10")`は["host01", "host02", ..., "host09", "host10"]を返します。

末尾のゼロを明示的に含める必要があります。そうでないと、下層のRuby関数が適切に機能しません。

第3の引数を渡すと、生成された領域がその間隔で刻まれます。例:

* `range("0", "9", "2")`は["0","2","4","6","8"]を返します。

*タイプ*: 右辺値

#### `regexpescape`

文字列または文字列の配列を正規表現エスケープします。インプットとして、単一の文字列または配列のいずれかが必要です。

*タイプ*: 右辺値

#### `reject`

配列を検索し、提示された正規表現に一致する要素をすべてリジェクトします。

たとえば、`reject(['aaa','bbb','ccc','aaaddd'], 'aaa')`は['bbb','ccc']を返します。

*タイプ*: 右辺値

#### `reverse`

文字列または配列の順序を逆転します。

*タイプ*: 右辺値

#### `rstrip`

文字列の右側のスペースを取り除きます。

*タイプ*: 右辺値

#### `seeded_rand`

整数の最大値と文字列のシード値を取り、最大値よりも小さい反復可能かつランダムな整数を返します。`fqdn_rand`と同様ですが、シードにノード固有のデータが追加されません。

*タイプ*: 右辺値

#### `shell_escape`

文字列をエスケープし、Bourneシェルコマンドラインで安全に使用できるようにします。得られる文字列はクォートなしで使用する必要があり、ダブルクォートまたはシングルクォートでの使用は意図されていません。この関数は、Rubyの`Shellwords.shellescape()`関数と同様に挙動します。[Rubyドキュメント](http://ruby-doc.org/stdlib-2.3.0/libdoc/shellwords/rdoc/Shellwords.html#method-c-shellescape)を参照してください。

例:

```puppet
shell_escape('foo b"ar') => 'foo\ b\"ar'
```

*タイプ*: 右辺値

#### `shell_join`

与えられた文字列の配列からコマンドライン文字列を構築します。各配列アイテムが、Bourneシェルで使用できるようにエスケープされます。その後、すべてのアイテムがまとめられ、間にシングルスペースが配されます。この関数は、Rubyの`Shellwords.shelljoin()`関数と同様に挙動します。[Rubyドキュメント](http://ruby-doc.org/stdlib-2.3.0/libdoc/shellwords/rdoc/Shellwords.html#method-c-shelljoin)を参照してください。

例:

```puppet
shell_join(['foo bar', 'ba"z']) => 'foo\ bar ba\"z'
```

*タイプ*: 右辺値

#### `shell_split`

文字列をトークンの配列に分割します。この関数は、Rubyの`Shellwords.shellsplit()`関数と同様に挙動します。[Rubyドキュメント](http://ruby-doc.org/stdlib-2.3.0/libdoc/shellwords/rdoc/Shellwords.html#method-c-shellsplit)を参照してください。

*例:*

```puppet
shell_split('foo\ bar ba\"z') => ['foo bar', 'ba"z']
```

*タイプ*: 右辺値

#### `shuffle`

文字列または配列の順序をランダム化します。

*タイプ*: 右辺値

#### `size`

文字列、配列、ハッシュの要素数を返します。この関数は、今後のリリースでは廃止されます。Puppet 4では、`length`関数を使用してください。

*タイプ*: 右辺値

#### `sort`

文字列と配列を語彙的に分類します。

*タイプ*: 右辺値

*注:* この関数はRubyクラスの実装にあたり、UTF8との互換性がない可能性があります。互換性を確保するには、Ruby 2.4.0以降でこの関数を使用してください。

#### `squeeze`

文字列内の連続した繰り返し('aaaa'など)を単一文字に置き換え、新たな文字列を返します。

*タイプ*: 右辺値

#### `str2bool`

特定の文字列をブーリアンに変換します。値'1'、'true'、't'、'y'、'yes'を含む文字列は`true`に変換されます。値'0'、'false'、'f'、'n'、'no'を含む文字列、および空文字列または未定義文字列は`false`に変換されます。その他の値の場合、エラーが生じます。このチェックでは、大文字と小文字は区別されません。

*タイプ*: 右辺値

#### `str2saltedsha512`

OS Xバージョン10.7以上で使用されるソルト付きSHA512パスワードハッシュに文字列を変換します。hexバージョンのソルト付きSHA512パスワードハッシュを返します。これは、有効なパスワード属性としてPuppetマニフェストに挿入することができます。

*タイプ*: 右辺値

*注:* この関数はRubyクラスの実装にあたり、UTF8との互換性がない可能性があります。互換性を確保するには、Ruby 2.4.0以降でこの関数を使用してください。

#### `strftime`

フォーマットされた時刻を返します。

たとえば、`strftime("%s")`はUnixエポックからの経過時間を返し、`strftime("%Y-%m-%d")`は日付を返します。

引数: `strftime`フォーマットで時間を指定する文字列。詳細については、Ruby [strftime](https://ruby-doc.org/core-2.1.9/Time.html#method-i-strftime)ドキュメントを参照してください。

*タイプ*: 右辺値

*注:* この関数はRubyクラスの実装にあたり、UTF8との互換性がない可能性があります。互換性を確保するには、Ruby 2.4.0以降でこの関数を使用してください。

*フォーマット:*

* `%a`: 曜日の名称の短縮形('Sun')
* `%A`: 曜日の完全な名称('Sunday')
* `%b`: 月の名称の短縮形('Jan')
* `%B`: 月の完全な名称('January')
* `%c`: 推奨される地域の日付および時刻の表現
* `%C`: 世紀(2009年であれば20)
* `%d`: その月の日(01..31)
* `%D`: 日付(%m/%d/%y)
* `%e`: その月の日、1桁の場合は半角空白で埋める( 1..31)
* `%F`: %Y-%m-%d(ISO 8601の日付フォーマット)と同等
* `%h`: %bと同等
* `%H`: 24時間制の時(00..23)
* `%I`: 12時間制の時(01..12)
* `%j`: 年中の通算日(001..366)
* `%k`: 24時間制の時、1桁の場合は半角空白で埋める( 0..23)
* `%l`: 12時間制の時、1桁の場合は半角空白で埋める( 0..12)
* `%L`: ミリ秒(000..999)
* `%m`: その年の月(01..12)
* `%M`: 分(00..59)
* `%n`: 改行(\n)
* `%N`: 秒の小数点以下の桁、デフォルトは9桁(ナノ秒)
  * `%3N`: ミリ秒(3桁)
  * `%6N`: マイクロ秒(6桁)
  * `%9N`: ナノ秒(9桁)
* `%p`: 午前または午後('AM'または'PM')
* `%P`: 午前または午後('am'または'pm')
* `%r`: 12時間制の時刻(%I:%M:%S %pと同等)
* `%R`: 24時間制の時刻(%H:%M)
* `%s`: Unixエポック、1970-01-01 00:00:00 UTCからの経過秒
* `%S`: 秒(00..60)
* `%t`: タブ文字(	)
* `%T`: 24時間制の時刻(%H:%M:%S)
* `%u`: 月曜日を1とした、曜日の数値表現(1..7)
* `%U`: 最初の日曜日を第1週の始まりとした、現在の週を表す数(00..53)
* `%v`: VMS形式の日付(%e-%b-%Y)
* `%V`: ISO 8601形式の暦週(01..53)
* `%W`: 最初の月曜日を第1週の始まりとした、現在の週を表す数(00..53)
* `%w`: 曜日(日曜が0、0..6)
* `%x`: 推奨される日付のみの表現、時刻はなし
* `%X`: 推奨される時刻のみの表現、日付はなし
* `%y`: 世紀なしの年(00..99)
* `%Y`: 世紀ありの年
* `%z`: タイムゾーン、UTCからのオフセット(+0900など)
* `%Z`: タイムゾーンの名称
* `%%`: '%'文字

#### `strip`

1つの文字列、または配列内のすべての文字列から、冒頭および末尾の空白を削除します。たとえば、`strip("    aaa   ")`は"aaa"になります。

*タイプ*: 右辺値

#### `suffix`

配列のすべての要素、またはハッシュのすべてのキーに接尾辞を適用します。

例:

* `suffix(['a','b','c'], 'p')`は['ap','bp','cp']を返します。
* `suffix({'a'=>'b','b'=>'c','c'=>'d'}, 'p')`は{'ap'=>'b','bp'=>'c','cp'=>'d'}を返します。

*タイプ*: 右辺値

#### `swapcase`

文字列の現在の大文字と小文字を入れ替えます。たとえば、`swapcase("aBcD")`は"AbCd"になります。

*タイプ*: 右辺値

*注:* この関数はRubyクラスの実装にあたり、UTF8との互換性がない可能性があります。互換性を確保するには、Ruby 2.4.0以降でこの関数を使用してください。

#### `time`

現在のUnixエポック時刻を整数として返します。

たとえば、`time()`は'1311972653'などを返します。

*タイプ*: 右辺値

#### `to_bytes`

引数をバイトに変換します。

たとえば、"4 kB"は"4096"になります。 

引数: 単一の文字列。

*タイプ*: 右辺値

#### `try_get_value`

**非推奨:** `dig()`に置き換えられました。

ハッシュおよび配列の複数レイヤー内の値を取得します。

引数: 

* 第1の引数として、パスを含む文字列。この引数は、ゼロではじまり、パス区切り文字(デフォルトは"/")で区切ったハッシュキーまたは配列インデックスの文字列として提示してください。この関数は各パスコンポーネントにより構造内を移動し、パスの最後で値を返すよう試みます。

*デフォルトの第2の引数。パスが正しくない場合や、値が見つからない場合、その他のエラーが生じた場合は、この引数が返されます。
* 最後の引数として、パス区切り文字。

```ruby
$data = {
  'a' => {
    'b' => [
      'b1',
      'b2',
      'b3',
    ]
  }
}

$value = try_get_value($data, 'a/b/2')
# $value = 'b3'

# 可能なすべてのオプションを使用
$value = try_get_value($data, 'a/b/2', 'not_found', '/')
# $value = 'b3'

# デフォルト値を使用
$value = try_get_value($data, 'a/b/c/d', 'not_found')
# $value = 'not_found'

# カスタム区切りを使用
$value = try_get_value($data, 'a|b', [], '|')
# $value = ['b1','b2','b3']
```

1. **$data** 取り扱うデータ構造。
2. **'a/b/2'** パス文字列。
3. **'not_found'** デフォルト値。何も見つからない場合に返されます。
   (オプション、デフォルトは`undef`)
4. **'/'** パス区切り文字。
   (オプション、デフォルトは*'/'*)

*タイプ*: 右辺値

#### `type3x`

**非推奨**。この関数は、今後のリリースで廃止されます。 

与えられた値のタイプを説明する文字列を返します。タイプとしては、文字列、配列、ハッシュ、フロート、整数、ブーリアンが可能です。Puppet 4では、この代わりに新しいタイプシステムを使用してください。

引数:

* 文字列
* 配列
* ハッシュ
* フロート
* 整数
* ブーリアン

*タイプ*: 右辺値

#### `type_of`

この関数は下位互換性を得るために提供されていますが、Puppetで提供されている内蔵の[type()関数](https://docs.puppet.com/puppet/latest/reference/function.html#type)の使用を推奨します。

与えられた値のリテラル型を返します。Puppet 4が必要です。`if type_of($some_value) <= Array[String] { ... }`のように(これは`if $some_value =~ Array[String] { ... }`に相当します)、`<=`を用いたタイプの比較に役立ちます。

*タイプ*: 右辺値

#### `union`

2つ以上の配列を重複なしで結合したものを返します。

たとえば、`union(["a","b","c"],["b","c","d"])`は["a","b","c","d"]を返します。

*タイプ*: 右辺値

#### `unique`

文字列および配列から重複を削除します。

たとえば、`unique("aabbcc")`は'abc'を、`unique(["a","a","b","b","c","c"])`は["a","b","c"]を返します。

*タイプ*: 右辺値

#### `unix2dos`

与えられた文字列のDOSバージョンを返します。クロスプラットフォームテンプレートでファイルリソースを使用する場合に役立ちます。

*タイプ*: 右辺値

```puppet
file{$config_file:
  ensure  => file,
  content => unix2dos(template('my_module/settings.conf.erb')),
}
```

[dos2unix](#dos2unix)も参照してください。

#### `upcase`

オブジェクト、配列、オブジェクトのハッシュを大文字に変換します。変換されるオブジェクトは、大文字化に対応するものでなければなりません。

たとえば、`upcase('abcd')`は'ABCD'を返します。

*タイプ*: 右辺値

*注:* この関数はRubyクラスの実装にあたり、UTF8との互換性がない可能性があります。互換性を確保するには、Ruby 2.4.0以降でこの関数を使用してください。

#### `uriescape`

文字列または文字列の配列をURLエンコードします。 

引数: 単一の文字列または文字列の配列。

*タイプ*: 右辺値

*注:* この関数はRubyクラスの実装にあたり、UTF8との互換性がない可能性があります。互換性を確保するには、Ruby 2.4.0以降でこの関数を使用してください。

#### `validate_absolute_path`

ファイルシステムの絶対パスを表す任意の文字列の有効性を確認します。WindowsおよびUnix形式のパスで機能します。

以下の値が渡されます:

```puppet
$my_path = 'C:/Program Files (x86)/Puppet Labs/Puppet'
validate_absolute_path($my_path)
$my_path2 = '/var/lib/puppet'
validate_absolute_path($my_path2)
$my_path3 = ['C:/Program Files (x86)/Puppet Labs/Puppet','C:/Program Files/Puppet Labs/Puppet']
validate_absolute_path($my_path3)
$my_path4 = ['/var/lib/puppet','/usr/share/puppet']
validate_absolute_path($my_path4)
```

以下の値は失敗になり、コンパイルが中止されます:

```puppet
validate_absolute_path(true)
validate_absolute_path('../var/lib/puppet')
validate_absolute_path('var/lib/puppet')
validate_absolute_path([ 'var/lib/puppet', '/var/foo' ])
validate_absolute_path([ '/var/lib/puppet', 'var/foo' ])
$undefined = `undef`
validate_absolute_path($undefined)
```

*タイプ*: ステートメント

#### `validate_array`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

渡されたすべての値が配列データ構造であることを確認します。このチェックで不合格となった値がある場合は、カタログコンパイルが中止されます。

以下の値が渡されます:

```puppet
$my_array = [ 'one', 'two' ]
validate_array($my_array)
```

以下の値は失敗になり、コンパイルが中止されます:

```puppet
validate_array(true)
validate_array('some_string')
$undefined = `undef`
validate_array($undefined)
```

*タイプ*: ステートメント

#### `validate_augeas`

Augeasレンズを用いて文字列を確認します。

引数:

* 第1の引数として、テストする文字列。
* 第2の引数として、使用するAugeasレンズの名前。
* オプションの第3の文字列として、ファイル内で見つかるべき**ではない**パスのリスト。
* オプションの第4の引数として、ユーザに表示するエラーメッセージ。

Augeasがレンズによる文字列の構文解析に失敗した場合は、構文エラーによりコンパイルが中止されます。 

`$file`変数は、Augeasツリーでテストされる一時ファイルのロケーションを示します。

たとえば、$passwdcontentにユーザの`foo`が含まれないようにするには、第3の引数を以下のようにします:

```puppet
validate_augeas($passwdcontent, 'Passwd.lns', ['$file/foo'])
```

エラーメッセージを生成して表示するには、第4の引数を以下のようにします:

```puppet
validate_augeas($sudoerscontent, 'Sudoers.lns', [], 'Failed to validate sudoers content with Augeas')
```

*タイプ*: ステートメント

#### `validate_bool`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

渡されたすべての値が`true`または`false`のいずれかであることを確認します。 
このチェックで不合格となった値がある場合は、カタログコンパイルが中止されます。

以下の値が渡されます:

```puppet
$iamtrue = true
validate_bool(true)
validate_bool(true, true, false, $iamtrue)
```

以下の値は失敗になり、コンパイルが中止されます:

```puppet
$some_array = [ true ]
validate_bool("false")
validate_bool("true")
validate_bool($some_array)
```

*タイプ*: ステートメント

#### `validate_cmd`

外部コマンドにより文字列を確認します。

引数:
* 第1の引数として、テストする文字列。
* 第2の引数として、テストコマンドのパス。この引数は、ファイルパスのプレースホルダ―として%をとります(%プレースホルダーが与えられていない場合、デフォルトはコマンド末尾)。パスした文字列を含む一時ファイルに対してコマンドが起動した場合や、ゼロではない値が返された場合は、構文エラーによりコンパイルが中止されます。
* オプションの第3の引数として、ユーザに表示するエラーメッセージ。

```puppet
# デフォルトのパス末尾
validate_cmd($sudoerscontent, '/usr/sbin/visudo -c -f', 'Visudo failed to validate sudoers content')
```

```puppet
# ファイルロケーションとして%を使用
validate_cmd($haproxycontent, '/usr/sbin/haproxy -f % -c', 'Haproxy failed to validate config content')
```

*タイプ*: ステートメント

#### `validate_hash`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

渡されたすべての値がハッシュデータ構造であることを確認します。このチェックで不合格となった値がある場合は、カタログコンパイルが中止されます。

以下の値が渡されます:

```puppet
$my_hash = { 'one' => 'two' }
validate_hash($my_hash)
```

以下の値は失敗になり、コンパイルが中止されます:

```puppet
validate_hash(true)
validate_hash('some_string')
$undefined = `undef`
validate_hash($undefined)
```

*タイプ*: ステートメント

#### `validate_integer`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

整数または整数の配列を確認します。いずれかがチェックで不合格になった場合には、カタログコンパイルが中止されます。

引数:

* 第1の引数として、整数または整数の配列。
* オプションの第2の引数として、最大値。第1の引数(のすべての要素)は、この最大値以下でなければなりません。
* オプションの第3の引数として、最小値。第1の引数(のすべての要素)は、この最小値以上でなければなりません。 

第1の引数が整数または整数の配列でない場合や、第2または第3の引数が整数に変換できない場合は、この関数は失敗になります。ただし、最小値が与えられている場合は(この場合に限られます)、第2の引数を空文字列または`undef`にすることが可能です。これは、最小チェックを確実に行うためのプレースホルダーとして機能します。

以下の値が渡されます:

```puppet
validate_integer(1)
validate_integer(1, 2)
validate_integer(1, 1)
validate_integer(1, 2, 0)
validate_integer(2, 2, 2)
validate_integer(2, '', 0)
validate_integer(2, `undef`, 0)
$foo = `undef`
validate_integer(2, $foo, 0)
validate_integer([1,2,3,4,5], 6)
validate_integer([1,2,3,4,5], 6, 0)
```

* 加えて、上述のすべて。ただし、文字列として渡された値を任意に組み合わせたもの('1'または"1")。
* 加えて、上述のすべて。ただし、負の整数値を(適切に)組み合わせたもの。

以下の値は失敗になり、コンパイルが中止されます:

```puppet
validate_integer(true)
validate_integer(false)
validate_integer(7.0)
validate_integer({ 1 => 2 })
$foo = `undef`
validate_integer($foo)
validate_integer($foobaridontexist)

validate_integer(1, 0)
validate_integer(1, true)
validate_integer(1, '')
validate_integer(1, `undef`)
validate_integer(1, , 0)
validate_integer(1, 2, 3)
validate_integer(1, 3, 2)
validate_integer(1, 3, true)
```

* 加えて、上述のすべて。ただし、文字列として渡された値を任意に組み合わせたもの (`false`、または"false")。
* 加えて、上述のすべて。ただし、負の整数値を不適切に組み合わせたもの。
* 加えて、上述のすべて。ただし、配列内の非整数アイテムまたは最大/最小引数を用いたもの。

*タイプ*: ステートメント

#### `validate_ip_address`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

IPv4アドレスかIPv6アドレスかにかかわらず、引数がIPアドレスであることを確認します。また、ネットマスクによりIPアドレスを確認します。 

引数: IPアドレスを指定する文字列。

以下の値が渡されます:

```puppet
validate_ip_address('0.0.0.0')
validate_ip_address('8.8.8.8')
validate_ip_address('127.0.0.1')
validate_ip_address('194.232.104.150')
validate_ip_address('3ffe:0505:0002::')
validate_ip_address('::1/64')
validate_ip_address('fe80::a00:27ff:fe94:44d6/64')
validate_ip_address('8.8.8.8/32')
```

以下の値は失敗になり、コンパイルが中止されます:

```puppet
validate_ip_address(1)
validate_ip_address(true)
validate_ip_address(0.0.0.256)
validate_ip_address('::1', {})
validate_ip_address('0.0.0.0.0')
validate_ip_address('3.3.3')
validate_ip_address('23.43.9.22/64')
validate_ip_address('260.2.32.43')
```


#### `validate_legacy`

指定したタイプおよび非推奨の確認関数の両方に照らして値を確認します。両方にパスした場合はそのままパスし、片方の確認のみにパスした場合はエラーが生じ、両方の確認でfalseが返された場合は失敗になります。

引数:

* 値のチェックに用いるタイプ。
* 過去の確認関数のフルネーム。
* チェックする値。
* 過去の確認関数に必要な引数の不特定数。

例:

```puppet
validate_legacy("Optional[String]", "validate_re", "Value to be validated", ["."])
```

この関数は、Puppet 3形式の引数確認(stdlibの`validate_*`関数を使用)からPuppet 4データタイプへのモジュールのアップデートに対応しており、Puppet 3形式の確認に頼っている場合も機能性が中断することはありません。

> 注: この関数は、Puppet 4.4.0 (PE 2016.1)以降にのみ対応しています。

##### モジュールユーザへ

Puppet 4を使用している場合、`validate_legacy`関数を使えば、非推奨のPuppet 3の`validate_*`関数を探し、分離することができます。これらの関数は、stdlibバージョン4.13時点で非推奨になっており、今後のstdlibバージョンでは削除されます。

Puppet 4では、[データタイプ](https://docs.puppet.com/puppet/latest/reference/lang_data.html)を用いた改良版の定義タイプチェックが可能です。データタイプでは、Puppet 3の`validate_*`関数で見られた、矛盾につながるいくつかの問題を回避できます。たとえば、[validate_numeric](#validate_numeric)では、数字だけでなく、数字の配列や数字のように見える文字列も意図せず許可されていました。

Puppet 4とともに、非推奨の `validate_*`関数を用いたモジュールを使用している場合は、非推奨メッセージが表示されることがあります。`validate_legacy`関数を使えば、そうした差異を可視化し、より明快なPuppet 4構文に簡単に移行することができます。

表示される非推奨メッセージは、使用しているモジュールやデータによって異なることがあります。以下の非推奨メッセージは、Puppet 4でのみデフォルトで表示されます:

* `Notice: Accepting previously invalid value for target type '<type>'`: このメッセージは、情報提供の目的のみで表示されるものです。使用している値は、新形式で許可されていますが、旧確認関数では無効となります。
* `Warning: This method is deprecated, please use the stdlib validate_legacy function`: モジュールがまだ`validate_legacy`にアップグレードされていません。[deprecation](#deprecation)オプションを使用してさしあたり警告を解除するか、モジュールの開発者によりフィックスを提出してください。この問題の解決方法については、以下の[モジュール開発者へ](#モジュール開発者へ)を参照してください。
* `Warning: validate_legacy(<function>) expected <type> value, got <actual type>_`: コードが渡す値は、Puppet 3形式の確認では認められますが、次バージョンのモジュールでは認められません。ほとんどの場合、数字またはブーリアンからクォートを削除すれば、この問題を解決することができます。
* `Error: Evaluation Error: Error while evaluating a Resource Statement, Evaluation Error: Error while evaluating a Function Call, validate_legacy(<function>) expected <type> value, got <actual type>`: コードの渡す値は、新形式の確認でも旧形式の確認でも認められません。

##### モジュール開発者へ

`validate_legacy`関数は、モジュールユーザの使用している機能を中断させずに、 Puppet 3形式の確認からPuppet 4形式の確認に移行するのに役立ちます。

Puppet 4形式の確認に移行すれば、[データタイプ](https://docs.puppet.com/puppet/latest/reference/lang_data.html)を用いた、より明確な定義タイプチェックが可能になります。Puppet 3の`validate_*` 関数の多くは、確認という点で驚くほど多くの穴があります。たとえば、[validate_numeric](#validate_numeric)では、細部をコントロールできないため、数字だけでなく、数字の配列や数字のように見える文字列も許可されます。 

クラスおよび定義タイプの各パラメータについて、使用する新しいPuppet 4データタイプを選択してください。たいていの場合、新しいデータタイプにより、元の`validate_*`関数とは異なる値のセットを使用できるようになります。以下のような状況になります:

|              | `validate_` pass | `validate_` fail |
| ------------ | ---------------- | ---------------- |
| マッチタイプ | パス             | パス、通告     |
| 失敗タイプ   | パス、非推奨 | 失敗             |

現在のところ、確認後のコードでも、すべての可能な値に対処する必要がありますが、新形式にマッチする値のみを渡すように、コードのユーザがマニフェストを変更することができます。

stdlibの`validate_*`関数それぞれについて、マッチする`Stdlib::Compat::*`タイプがあり、適切な値のセットが許可されます。注意事項については、stdlibソースコードの `types/`ディレクトリにあるドキュメントを参照してください。

たとえば、数字のみが許可されるクラスを与えると、以下のようになります:

```puppet
class example($value) {
  validate_numeric($value)
```

得られる確認コードは、以下のようになります:

```puppet
class example(
  Variant[Stdlib::Compat::Numeric, Numeric] $value
) {
  validate_legacy(Numeric, 'validate_numeric', $value)
```

ここでは、`$value`のタイプが`Variant[Stdlib::Compat::Numeric, Numeric]`と定義されています。これにより、任意の`Numeric` (新形式)のほか、`validate_numeric`で(`Stdlib::Compat::Numeric`を通じて)これまで許可されていたすべての値を使用できます。

`validate_legacy`を呼び出すと、適切なログまたは失敗メッセージのトリガーが処理されます。これには、新形式、以前の確認関数の名称、およびその関数のすべての引数が必要です。

お使いのモジュールがまだPuppet 3をサポートしている場合は、これは互換性を破る変更になります。`metadata.json`要件セクションをアップデートしてモジュールがもうPuppet 3をサポートしていないことを示し、モジュールのメジャーバージョンを放棄してください。この変更を加えても、モジュールに関する既存のすべてのテストにパスするはずです。新たに可能になった値について、追加のテストを作成してください。

これは互換性を破る変更であることから、取り除きたいすべてのパラメータについて [`deprecation`](#deprecation)をコールしたり、パラメータにさらなる制約を追加したりする良い機会でもあります。

このバージョンのリリース後、互換性を破る変更を加えた別のリリースを公開し、すべての互換性タイプおよび `validate_legacy`のコールを削除することができます。その時点で、コードを実行し、過去に可能だった値に関する残余要素を取り除くこともできます。

そうした変更については、必ずCHANGELOGおよびREADMEで通告してください。

#### `validate_numeric`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

数値または数値の配列や文字列を確認します。いずれかがチェックに失敗した場合には、カタログコンパイルが中止されます。

引数:

* 数値、または数値の配列か文字列。
* オプションで、最大値。第1の引数(のすべての要素) は、この最大値以下でなければなりません。
* オプションで、最小値。第1の引数(のすべての要素)は、この最小値以上でなければなりません。

第1の引数が数値(整数またはフロート)または数値の配列が文字列でない場合や、第2および第3の引数が数値に変換できない場合は、この関数は失敗になります。最小値が与えられている場合は(この場合に限られます)、第2の引数を空文字列または`undef`にすることが可能です。これは、最小チェックを確実に行うためのプレースホルダーとして機能します。

パスおよび失敗の使用については、[`validate_integer`](#validate-integer)を参照してください。同じ値がパスおよび失敗します。ただし、`validate_numeric`では、浮動小数点値も許可されます。

*タイプ*: ステートメント

#### `validate_re`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

1つまたは複数の正規表現に照らして、文字列の簡単な確認を行います。

引数:

* 第1の引数として、テストする文字列。この引数が文字列でない場合、コンパイルが中止されます。クォートを用いて強制的に文字列化してください。
* 第2の引数として、文字列化した正規表現(区切り文字//なし)または正規表現の配列。
* オプションの第3の引数として、ユーザに表示するエラーメッセージ。

第2の引数の正規表現が第1の引数で渡した文字列にマッチしない場合は、構文エラーによりコンパイルが中止されます。

以下の文字列により、正規表現に照らして確認が行われます:

```puppet
validate_re('one', '^one$')
validate_re('one', [ '^one', '^two' ])
```

以下の文字列では、確認に失敗し、コンパイルが中止されます:

```puppet
validate_re('one', [ '^two', '^three' ])
```

エラーメッセージの設定方法:

```puppet
validate_re($::puppetversion, '^2.7', 'The $puppetversion fact value does not match 2.7')
```

強制的に文字列化するには、クォートを使用してください:

  ```
  validate_re("${::operatingsystemmajrelease}", '^[57]$')
  ```

*タイプ*: ステートメント

#### `validate_slength`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

文字列(または文字列の配列)が指定した長さ以下であることを確認します。

引数:

* 第1の引数として、文字列または文字列の配列。
* 第2の引数として、長さの最大値を示す数値。
* オプションの第3の引数として、長さの最小値を示す数値。

  以下の値が渡されます:

```puppet
validate_slength("discombobulate",17)
validate_slength(["discombobulate","moo"],17)
validate_slength(["discombobulate","moo"],17,3)
```

以下の値は失敗になります:

```puppet
validate_slength("discombobulate",1)
validate_slength(["discombobulate","thermometer"],5)
validate_slength(["discombobulate","moo"],17,10)
```

*タイプ*: ステートメント

#### `validate_string`

**非推奨。今後のバージョンのstdlibでは削除されます。[`validate_legacy`](#validate_legacy)を参照してください。**

渡したすべての値が文字列データ構造であることを確認します。このチェックに失敗した値がある場合は、カタログコンパイルが中止されます。

以下の値が渡されます:

```puppet
$my_string = "one two"
validate_string($my_string, 'three')
```

以下の値は失敗になり、コンパイルが中止されます:

```puppet
validate_string(true)
validate_string([ 'some', 'array' ])
```

*注:* validate_string(`undef`)は、このバージョンの関数APIでは失敗しません。

代わりに、以下を使用してください:

  ```
  if $var == `undef` {
    fail('...')
  }
  ```

*タイプ*: ステートメント

#### `validate_x509_rsa_key_pair`

OpenSSLにより、PEMフォーマットされたX.509認証およびプライベートキーを確認します。
認証の署名が提供されたキーから作成されたものであることを確認します。

このチェックに失敗した値がある場合は、カタログコンパイルが中止されます。

引数:

* 第1の引数として、X.509認証。
* 第2の引数として、RSAプライベートキー。

```puppet
validate_x509_rsa_key_pair($cert, $key)
```

*タイプ*: ステートメント

#### `values`

与えられたハッシュの値を返します。

たとえば、`$hash = {'a'=1, 'b'=2, 'c'=3} values($hash)`を与えると、[1,2,3]を返します。

*タイプ*: 右辺値

#### `values_at`

ロケーションをもとに、配列内の値を探します。

引数:

* 第1の引数として、解析したい配列。
* 第2の引数として、以下の値の任意の組み合わせ:
  * 単一の数値インデックス。
  * 'start-stop'の形式での範囲(4-9など)。
  * 上記を組み合わせた配列。

例:

* `values_at(['a','b','c'], 2)`は['c']を返します。
* `values_at(['a','b','c'], ["0-1"])`は['a','b']を返します。
* `values_at(['a','b','c','d','e'], [0, "2-3"])`は['a','c','d']を返します。

*タイプ*: 右辺値

#### `zip`

与えられた第1の配列から1つの要素をとり、与えられた第2の配列の対応する要素と結合します。これにより、n-要素配列のシーケンスが生成されます。*n*は、引数の数より1大きくなります。たとえば、`zip(['1','2','3'],['4','5','6'])`は["1", "4"], ["2", "5"], ["3", "6"]を返します。*タイプ*: 右辺値。

## 制約

Puppet Enterprise 3.7では、stdlibモジュールがPEに含まれていません。PEユーザは、Puppetと互換性のあるstdlibの最新リリースをインストールする必要があります。

### バージョン互換性

バージョン | Puppet 2.6 | Puppet 2.7 | Puppet 3.x | Puppet 4.x |
:---------------|:-----:|:---:|:---:|:----:
**stdlib 2.x**  | **あり** | **あり** | なし | なし
**stdlib 3.x**  | なし    | **あり**  | **あり** | なし
**stdlib 4.x**  | なし    | **あり**  | **あり** | なし
**stdlib 4.6+**  | なし    | **あり**  | **あり** | **あり**
**stdlib 5.x**  | なし    | なし  | **あり**  | **あり**

**stdlib 5.x**:  stdlib 5.xのリリース時には、Puppet 2.7.xのサポートが廃止されます。[この説明](https://github.com/puppetlabs/puppetlabs-stdlib/pull/176#issuecomment-30251414)を参照してください。

## 開発

Puppet ForgeのPuppet Labsモジュールはオープンプロジェクトで、良い状態に保つためには、コミュニティの貢献が必要不可欠です。Puppetが役に立つはずでありながら、私たちがアクセスできないプラットフォームやハードウェア、ソフトウェア、デプロイ構成は無数にあります。私たちの目標は、できる限り簡単に変更に貢献し、みなさまの環境で私たちのモジュールが機能できるようにすることにあります。最高の状態を維持できるようにするために、コントリビュータが従う必要のあるいくつかのガイドラインが存在します。詳細については、[モジュールコントリビューションガイド](https://docs.puppetlabs.com/forge/contributing.html)を参照してください。

このモジュールのバグの報告または調査は、
[http://tickets.puppetlabs.com/browse/MODULES](http://tickets.puppetlabs.com/browse/MODULES)からお願いします。

## コントリビュータ

コントリビュータのリストは、[https://github.com/puppetlabs/puppetlabs-stdlib/graphs/contributors](https://github.com/puppetlabs/puppetlabs-stdlib/graphs/contributors)で見ることができます。