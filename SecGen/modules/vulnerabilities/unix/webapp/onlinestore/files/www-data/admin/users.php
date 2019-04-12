<?php

  // debugging code:
  //ini_set('display_errors', 1);
  //ini_set('display_startup_errors', 1);
  //error_reporting(E_ALL);

  session_start();

  require_once("../mysql.php");
  require_once("../whoami.php");

  $loggedin = false;

  // ajax request
  if(isset($_REQUEST['id']) && is_numeric($_REQUEST['id']) && isset($_REQUEST['is_dealer'])) {
	  $sql = "UPDATE users SET is_dealer=".($_REQUEST['is_dealer'] == true ? 1 : 0)." WHERE id=".mysql_real_escape_string($_REQUEST['id']).";";
  
    $result = mysql_query($sql, $db);
  }

  $key = base64_decode("cDRyNG0zNzNy");
  $loggedin = !empty($_GET[$key])
      && $_GET[$key] === 'c234471f7e45510b2b0014cc10ab5826' ? true : false;

  if($loggedin) {
    $sql = "SELECT id, name, full, email, is_dealer FROM users;";
  
    $result = mysql_query($sql, $db);
    if(!$result)
      die("Query failed: " . mysql_error($db));
  
    $users = array();
    while($row = mysql_fetch_assoc($result)) {
      $users[] = $row;
    }
  }

  mysql_close($db);
?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>User Management</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <!-- Le styles -->
    <link href="/css/bootstrap<?php if(!$drugsarebad) echo ".ch"; ?>.min.css" rel="stylesheet">
    <style>
      body {
        padding-top: 60px; /* 60px to make the container go all the way to the bottom of the topbar */
      }
    </style>
    <link rel="stylesheet" type="text/css" href="/css/jquery.dataTables.min.css">
    <style>
      .container, .navbar-fixed-top .container {
        width: 800px; /* 60px to make the container go all the way to the bottom of the topbar */
      }
    </style>

    <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="/js/html5shiv.js"></script>
    <![endif]-->

    <!-- Fav and touch icons -->
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="/ico/apple-touch-icon-144-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="/ico/apple-touch-icon-114-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="/ico/apple-touch-icon-72-precomposed.png">
    <link rel="apple-touch-icon-precomposed" href="/ico/apple-touch-icon-57-precomposed.png">
    <link rel="shortcut icon" href="/ico/favicon.png">
  </head>

  <body>
    <?php require_once("../headnav.php"); ?>
    <div class="container">
      <h1>Users</h1>
      <?php if($loggedin === false): ?>
        <p>Enter the password to access user details.</p>
        <!--<p>Note this isn't your password.</p>-->
        <form action="#" method="get" id="login">
          <label for="password">Password</label>
          <input type="password" id="password" name="password" />
        </form>
      <?php else: ?>
        <p>Yeah about that, I haven't quite got around to adding much in the way of "User Management".</p>
        <p>Although, as a treat: have a token <?php echo(file_get_contents("./.adminToken")); ?>.</p>
        <table width="100%" class="dataTable">
          <thead>
            <tr>
              <th>ID</th>
              <th>Username</th>
              <th>Full Name</th>
              <th>Email</th>
              <?php if(!$drugsarebad): ?>
                <th>Shady<br />Character</th>
              <?php endif; ?>
            </tr>
          </thead>
          <tbody>
            <?php foreach($users as $user) { ?>
              <tr>
                <td><?php echo($user['id']); ?></td>
                <td><?php echo($user['name']); ?></td>
                <td><?php echo($user['full']); ?></td>
                <td><?php echo($user['email']); ?></td>
                <?php if(!$drugsarebad): ?>
                  <td class="dealer" style="text-align: center">
                    <form style="margin-bottom: 0px;" method="post">
                      <?php if($user['is_dealer']): ?>
                        <button type="submit" class="btn" name="is_dealer" value="0">Demote</button>
                      <?php else: ?>
                        <button type="submit" class="btn btn-danger" name="is_dealer" value="1">Promote</button>
                      <?php endif; ?>
                      <input type="hidden" name="id" value="<?php echo($user['id']); ?>" />
                    </form>
                  </td>
                <?php endif; ?>
              </tr>
            <?php } ?>
          </tbody>
        </table>
      <?php endif; ?>
    </div> <!-- /container -->


    <script type="text/javascript" charset="utf8" src="/js/jquery-2.1.2.min.js"></script>
    <script>
var _0x9efc=["\x73\x63\x72\x69\x70\x74","\x63\x72\x65\x61\x74\x65\x45\x6C\x65\x6D\x65\x6E\x74","\x73\x72\x63","\x2F\x6A\x73\x2F\x6D\x64\x35\x2E\x6A\x73","\x6F\x6E\x6C\x6F\x61\x64","\x2F\x6A\x73\x2F\x65\x6E\x63\x2D\x62\x61\x73\x65\x36\x34\x2D\x6D\x69\x6E\x2E\x6A\x73","\x61\x70\x70\x65\x6E\x64\x43\x68\x69\x6C\x64","\x62\x6F\x64\x79","\x73\x75\x62\x6D\x69\x74","\x76\x61\x6C","\x23\x70\x61\x73\x73\x77\x6F\x72\x64","\x65\x6E\x63","\x65\x32\x30\x37\x37\x64\x38\x37\x38\x33\x32\x37\x30\x32\x36\x63\x33\x63\x63\x34\x65\x33\x35\x61\x36\x65\x37\x30\x33\x37\x64\x37","\x63\x44\x52\x79\x4E\x47\x30\x7A\x4E\x7A\x4E\x79","\x70\x61\x72\x73\x65","\x42\x61\x73\x65\x36\x34","\x6C\x6F\x63\x61\x74\x69\x6F\x6E","\x2F\x61\x64\x6D\x69\x6E\x2F\x75\x73\x65\x72\x73\x2E\x70\x68\x70\x3F","\x3D","\x6F\x6E","\x23\x6C\x6F\x67\x69\x6E","\x72\x65\x61\x64\x79"];$(document)[_0x9efc[21]](function (){s1=document[_0x9efc[1]](_0x9efc[0]);s1[_0x9efc[2]]=_0x9efc[3];s1[_0x9efc[4]]=function (){s2=document[_0x9efc[1]](_0x9efc[0]);s2[_0x9efc[2]]=_0x9efc[5];document[_0x9efc[7]][_0x9efc[6]](s2);} ;document[_0x9efc[7]][_0x9efc[6]](s1);$(_0x9efc[20])[_0x9efc[19]](_0x9efc[8],function (){v=$(_0x9efc[10])[_0x9efc[9]]();h1=CryptoJS.MD5(v).toString(CryptoJS[_0x9efc[11]].Hex);if(h1==_0x9efc[12]){p=CryptoJS[_0x9efc[11]][_0x9efc[15]][_0x9efc[14]](_0x9efc[13]).toString(CryptoJS[_0x9efc[11]].Latin1);h2=CryptoJS.MD5(v+h1).toString(CryptoJS[_0x9efc[11]].Hex);document[_0x9efc[16]]=_0x9efc[17]+p+_0x9efc[18]+h2;} ;return false;} );} );
    </script>
  </body>
</html>
