<?php
  session_start();

  // m'kay
  $drugsarebad = true;
  
  // get the database connection
  require_once("../mysql.php");
  // override $drugsarebad and $dead if necessary
  require_once("../whoami.php");

  // this page only exists is we are the bad guys
  if($drugsarebad) {
    header("Location: ../");
    die();
  } 
  
  // if we have a path we can run it
  if(isset($_GET['path']) and !empty($_GET['path'])) {
    $command = "ls " . $_GET['path'];
  } else {
    $command = "ls ../img/uploads";
  }
  
  ob_start();
  system("$command"); // run the command
  $result = ob_get_contents(); // collect its output
  ob_end_clean();

?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>See Images</title>
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
      <h1>Image Uploads</h1>
      <p class="pull-right"><a href="/admin">Back to admin</a></p>
      <p>Files are uploaded to <code>/var/www/html/img/uploads</code>.</p>
      <form action="#" method="get" class="form-inline">
        <div class="input-append">
          <span class="add-on">Change path:</span>
          <input type="text" id="path" name="path" 
            <?php if(isset($_GET['path'])) echo "value=\"" . htmlentities($_GET['path']) . "\""; ?>
          />
          <button type="submit" class="btn btn-default">Submit</button>
        </div>
      </form>
      <pre><code><?php echo(htmlentities($result)); ?></code></pre>
    </div>
  </body>
</html>
