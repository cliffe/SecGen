<?php
  session_start();

  $drugsarebad = true; 
  $dead = false;

  // override $drugsarebad and $dead if appropriate.
  require_once("whoami.php");

  // if we're not dead ...
  if(!$dead) {
    // ... use the application
    header("Location: /");
    die();
  }
?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Sorry but soon you'll be dead.</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <!-- Le styles -->
    <link href="/css/bootstrap<?php if(!$drugsarebad) echo(".ch"); ?>.min.css" rel="stylesheet">
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
    <?php include("headnav.php"); ?>
    <div class="container">
      <p>Well this is awkward, you'd better run. We'll be ... with you shortly.</p>
      <?php if(isset($row) and $row['killed_by'] == $_SESSION['user']['id']): ?>
        <p class="text-warning"><small>The embarrassing part of all of this is that you were the one that called it in. Sorry no refunds.</small></p>
      <?php endif; ?>
    </div> <!-- /container -->
  </body>
</html>
