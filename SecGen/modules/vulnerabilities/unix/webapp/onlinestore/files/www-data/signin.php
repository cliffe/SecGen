<?php
  session_start();

  // m'kay
  $drugsarebad = true;
  
  // get the database connection
  require_once("mysql.php");
  // override $drugsarebad and $dead if necessary
  require_once("whoami.php");

  // are we not already logged in?
  if(isset($_SESSION['user'])) {
    header("Location: /index.php");
  }

  // POST only
  if($_SERVER["REQUEST_METHOD"] == "POST") {
    // authenticate
	$sql = "SELECT id, name, full, is_dealer FROM users WHERE password='" . 
	      mysql_real_escape_string($_POST['password']) . "' AND name='" . $_POST['username'] . "';";

    $result = mysql_query($sql, $db);
    if(!$result)
      die("Query failed: " . mysql_error());

    // do we have a user that matches?
    if(mysql_num_rows($result) > 0) {
      $row = mysql_fetch_assoc($result); 
      session_regenerate_id(); // safety (session freshness, can't be bad).
      setcookie(
          /* md5('dealer'), they'll never know :) */
          "040ec1ee950ffc53291f6df0ffc30325", 
          md5($row['is_dealer']));
      // maintain user information in the session
      $_SESSION['user'] = $row;
      mysql_close($db);
      // login
      header("Location: /index.php");
      die();
    }

    mysql_close($db);
  }
?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Signin</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <!-- Le styles -->
    <link href="/css/bootstrap<?php if(!$drugsarebad) echo(".ch"); ?>.min.css" rel="stylesheet">
    <style type="text/css">
      body {
        padding-top: 40px;
        padding-bottom: 40px;
        background-color: #f5f5f5;
      }

      .form-signin {
        max-width: 300px;
        padding: 19px 29px 29px;
        margin: 0 auto 20px;
        background-color: #fff;
        border: 1px solid #e5e5e5;
        -webkit-border-radius: 5px;
           -moz-border-radius: 5px;
                border-radius: 5px;
        -webkit-box-shadow: 0 1px 2px rgba(0,0,0,.05);
           -moz-box-shadow: 0 1px 2px rgba(0,0,0,.05);
                box-shadow: 0 1px 2px rgba(0,0,0,.05);
      }
      .form-signin .form-signin-heading,
      .form-signin .checkbox {
        margin-bottom: 10px;
      }
      .form-signin input[type="text"],
      .form-signin input[type="password"] {
        font-size: 16px;
        height: auto;
        margin-bottom: 15px;
        padding: 7px 9px;
      }

    </style>
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
    <?php require_once("headnav.php"); ?>
    <div class="container">
      <form action="signin.php" method="post" class="form-signin">
      <?php
        if($_SERVER["REQUEST_METHOD"] == "POST") {
        ?>
          <div class="alert alert-error alert-dismissable">
            <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
            Your credentials were invalid.
          </div>
        <?php
        }
      ?>
        <h2 class="form-signin-heading">Please sign in</h2>
        <input name="username" type="text" class="input-block-level" placeholder="Username" />
        <input name="password" type="password" class="input-block-level" placeholder="Password" />
        <button class="btn btn-large btn-primary" type="submit">Sign in</button>
      </form>
    </div> <!-- /container -->
  </body>
</html>
