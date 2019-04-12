<?php
  session_start();
  // m'kay
  $drugsarebad = true;
  
  // override $drugsarebad and $dead if necessary
  require_once("whoami.php");
?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Welcome to furniture!</title>
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
    <script type="text/javascript" src="js/news.js"></script>
    <link type="text/css" rel="stylesheet" href="css/news.css"/>
  </head>

  <body onload="initialise();">
    <?php include("headnav.php"); ?>
    <div class="container">
      <?php if(!$drugsarebad): ?>
        <h1>The Cotton Highway</h1>
	   <p>We have drugs, get your drugs here, also a token:  <?php echo(file_get_contents("./.marketToken")); ?><br/>
        <small class="muted">And a <em>hit</em> here and there.</small></p>
      <?php else: ?>
        <h1>Sensible Furniture.</h1>
        <p>Or as sensible as furntiture can be! We have tables, beds and what not.</p>
        <div class="row">
          <img src="/img/FPG1.png" class="span5"/>
          <img src="/img/FPG2.png" class="span5"/>
        </div>
      <?php endif ?>
    </div> <!-- /container -->
    <div id="news">
    <h2>News</h2>
      <div id="preview_list">
        <ul>
        </ul>
      </div>
      <div id="story_pane">
        <ul>
        </ul>
      </div>
    </div>
  </body>
</html>
