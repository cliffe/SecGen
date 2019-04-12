<?php
  session_start();

  //if(!isset($_COOKIE['is_admin']) || $_COOKIE['is_admin'] != 1) {
  //  header("Location: /signin.php");
  //  die();
  //}

  $json = null;

  require_once('../../whoami.php');

  if(isset($_GET['message']) and ctype_alnum($_GET['message'])) {
    $message = $_GET['message'];

    ob_start();
    system("cat $message");
    $file = ob_get_contents();
    ob_end_clean();

    $json = json_decode($file);
  } else {
    if($dir = opendir(".")) {
      while(($file = readdir($dir)) !== false) {
        if(preg_match("/^id[A-Za-z0-9]+/", $file)) {
          $read = file_get_contents($file);
          $data = json_decode($read);
          $data->id = $file;
          $json[] = $data;
        }
      }
    }
  }
?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Messages (Contact Us)</title>
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
    <?php require_once("../../headnav.php"); ?>
    <div class="container">
      <h1>Recieved Messages</h1>
      <p>Only by an email will they get this URL.</p>
      <p>For my eyes only.</p>
      <?php if(isset($_GET['message'])) { ?>
        <p>Back to the list of <a href="?">Recieved Messages</a></p>
        <?php if($json != null) { ?>
          <fieldset>
            <legend>The Message</legend>
            <label>Name</label>
            <input name="name" type="text" disabled="disabled" value="<?php echo($json->name); ?>"/>
            <label>Email</label>
            <input name="email" type="email" disabled="disabled" value="<?php echo(htmlentities($json->email)); ?>"/>
            <label>Message</label>
            <textarea disabled="disabled" name="message" rows="3" style="width:400px"><?php echo(htmlentities($json->message)); ?></textarea>
          </fieldset>
        <?php } else { ?>
          <div class="alert alert-error">
            <p>The file I've been given isn't JSON ...</p>
            <textarea disabled="disabled" name="message" rows="10" style="width:100%"><?php echo(htmlentities($file)); ?></textarea>
          </div>
        <?php } ?>
      <?php } else { ?>
        <?php if($json != null) { ?>
          <ul>
            <?php foreach($json as $message): ?>
              <li>
                <a href="?message=<?php echo($message->id); ?>">
                  <?php echo(htmlentities($message->name)); ?> &lt;<?php echo($message->email); ?>&gt;
                </a>
              </li>
            <?php endforeach; ?>
          </ul>
        <?php } else { ?>
          <p><em>-- There are no messages --</em></p>
        <?php } ?>
      <?php } ?>
    </div> <!-- /container -->
  </body>
</html>
