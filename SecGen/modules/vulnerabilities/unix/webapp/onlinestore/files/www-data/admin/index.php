<?php
  session_start();

  // m'kay
  $drugsarebad = true;
  
  // override $drugsarebad and $dead if necessary
  require_once("../whoami.php");
?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Administrator Panel</title>
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
      <h1>Administrator Panel</h1>
      <h4>Promote and demote users.</h4>
      <p><a href="/admin/users.php">User Management</a></p>
      <hr />
      <h4>Product Management</h4>
      <p><a href="/admin/upload.php">Add New Products</a></p>
      <p><a href="/admin/list.php">See File Uploads (Images)</a></p>
      <h4>Messages</h4>
      <p><a href="/admin/m/">View messages send by the public</a></p>
    </div> <!-- /container -->
  </body>
</html>
