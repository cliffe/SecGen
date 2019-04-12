<?php
  session_start();

  // m'kay
  $drugsarebad = true;
  
  // override $drugsarebad and $dead if necessary
  require_once("whoami.php");

  /* have we sent the message */
  $sent = false; /* for later */
  $bademail = false;

  // have we been sent by a form?
  if($_SERVER["REQUEST_METHOD"] == "POST") {
    if(strstr($_POST['email'], "@") !== false) {
      // where to store messages
      $dir = "admin/m";
      if(!is_dir($dir)) {
        mkdir($dir);
        chmod($dir, 0770);
      }
  
      // create the file
      $filename = tempnam($dir, "id");
      $handle = fopen($filename, "w");
      $arr = array(
        "name" => $_POST['name'],
        "email" => $_POST['email'],
        "message" => $_POST['message'],
        "time" => time()
      );
      fwrite($handle, json_encode($arr));
      fclose($handle);
      chmod($filename, 0770);
      $sent = true;
    } else {
      $bademail = true;
    }
  }
?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Contact Us</title>
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
      <?php
        if($_SERVER["REQUEST_METHOD"] == "POST") {
          if($sent == true) {
        ?>
          <div class="alert alert-success alert-dismissable">
            <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
            Your message has been sent.
          </div>
        <?php
          } else {
        ?>
          <div class="alert alert-error alert-dismissable">
            <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
            Your message hasn't been sent.
          </div>
        <?php
  
          }
        }
      ?>
      <h1>Contact Me!</h1>
      <p>My name is Joe Bloggs, I have a nice shop don"t you think?</p>
      <p>I know, I know, it is a <em>little</em> plain, but I am not a designer.</p>
      <p>If you know a designer, send me his details.</p>
      <form action="contact.php" method="post">
        <fieldset>
          <legend>Contact Form</legend>
          <label>Name</label>
          <input name="name" type="text" placeholder="Your name..." />
          <label>Email</label>
          <?php if($bademail) { ?>
            <div class="control-group error">
          <?php } ?>
          <input name="email" type="text" placeholder="Your email..."/>
          <?php if($bademail) { ?>
            </div>
          <?php } ?>
          <label>Message</label>
          <textarea name="message" rows="3" style="width:400px" placeholder="Your message..."></textarea>
          <input name="to" type="hidden" value="csecvm@gmail.com" />
          <div class="form-actions">
            <button type="submit" class="btn btn-primary">Send</button>
            <button type="reset" class="btn">Clear</button>
          </div>
        </fieldset>
      </form>
    </div> <!-- /container -->
  </body>
</html>
