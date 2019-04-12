<?php

session_start();

require_once("../whoami.php");

$errors = array();

function x($id) {
  if($_POST && !empty($_POST[$id]))
    echo htmlentities($_POST[$id]);
}

$done = false;

// posted?
if($_POST) {
  // csrf check?
  if($_SESSION["csrf"] == $_POST["csrf"]) {
    $target = "/var/www/html/img/uploads/" . basename($_POST["filename"]);
    //quick error check: this makes sure that the uploaded file
    //has the same extension as the new file name we generate for this
    if(@pathinfo($_FILES["file"]["name"], PATHINFO_EXTENSION)
        == @pathinfo($_POST["filename"], PATHINFO_EXTENSION)) {
      if(move_uploaded_file($_FILES["file"]["tmp_name"], $target)) {
        $danger = $drugsarebad ? 0 : (is_numeric($_POST["danger"]) and in_array($_POST["danger"], array(0, 1))) ? $_POST["danger"] : 0;
        require_once("../mysql.php");
  
  	  	$sql = "INSERT INTO products (name, description, image, danger, price) VALUES('".mysql_real_escape_string(htmlentities($_POST["name"]))."', '".
          mysql_real_escape_string(htmlentities($_POST["desc"]))."', '".
          mysql_real_escape_string("/img/uploads/" . basename($_POST["filename"]))."', '".
          mysql_real_escape_string($danger)."', '".
          mysql_real_escape_string($_POST['price'])."');";
  
        $result = mysql_query($sql);
        if(!$result) {
          $errors[] = mysql_error();
          unlink($target);
        } else {
          $done = true;
        }
  
        mysql_close();
      } else {
        $errors[] = "I was unable to move the file to the right place.";
      }
    } else {
      $errors[] = "This file isn't a JPG file.";
    }
  } else {
    $errors[] = "CSRF Token doesn't match.";
  }
}

//we need to make sure that the uploaded file does not have the same
//name as a file we already have. Therefore this generates a new 
//random name for the file
$file = basename(@tempnam("/var/www/html/img/uploads", strftime("%Y-%m-%d_", time())));
$file .= ".jpg";

// refresh csrf token
$csrf = md5(time());
$_SESSION["csrf"] = $csrf;

?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Create a Product</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <!-- Le styles -->
    <link href="/css/bootstrap<?php if(!$drugsarebad) echo(".ch"); ?>.min.css" rel="stylesheet">
    <style>
      body {
        padding-top: 60px; /* 60px to make the container go all the way to the bottom of the topbar */
      }

input[readonly] {
  background-color: white !important;
  cursor: text !important;
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
      <p class="pull-right"><a href="/admin">Back to admin</a></p>
      <h1>New Item</h1>
      <?php if(count($errors) > 0): ?>
        <div class="alert alert-warning alert-dismissible" role="alert">
          <?php foreach($errors as $error): ?>
            <?php echo $error; ?>
          <?php endforeach; ?>
        </div>
      <?php endif; ?>
      <?php if($done): ?>
        <div class="alert alert-info alert-dismissible" role="alert">
          New product has been uploaded. Go to the <a href="/product.php">products page</a> if you like.
        </div>
      <?php endif; ?>
      <form method="post" action="#" enctype="multipart/form-data">
        <label for="name">Name</label>
        <input id="name" name="name" type="text" placeholder="Name of the item." value="<?php x("name"); ?>" />
        <label for="desc">Description</label>
        <textarea id="desc" name="desc" rows="5" class="input-xxlarge"><?php x("desc"); ?></textarea>       
        <div class="input">
          <div class="input-prepend">
            <label class="btn btn-primary" for="file">
              Upload an image ...
              <input id="file" name="file" type="file" style="display: none;" />
            </label>
            <input id="path" type="text" readonly="readonly" placeholder="No file selected." />
          </div>
        </div>
        <small class="muted">(this must be a <em>jpg</em> file.)</small>
        <br />
        <br />
        <?php if(!$drugsarebad): ?>
          <legend>What ... <em>type</em> of product is this?</legend>
          <label class="radio">
            <input type="radio" name="danger" value="0" />
            Only for the general public.
          </label>
          <label class="radio">
            <input type="radio" name="danger" value="1" checked="checked" />
            Only for us miscreants <small class="muted">by default, just in case you"re an idiot!</small>
          </label>
        <?php endif; ?>
        <label for="price">Price</label>
        <input type="text" id="price" name="price" value="<?php x("price"); ?>"/>
        <input type="hidden" value="<?php echo($csrf); ?>" name="csrf" />
        <input type="hidden" value="<?php echo(htmlentities($file)); ?>" name="filename" />
        <div class="form-actions">
          <button type="submit" class="btn btn-primary">Save changes</button>
          <button type="reset" class="btn btn-default">Clear</button>
        </div>
      </form>
    </div>
    <script>
      $(document).ready(function() {
        $("#file").on("change", function() {
          $("#path").val(
            $(this).val().replace(/\\/g, "/").replace(/.*\//, "")
          );
        });
      });
    </script>
  </body>
</html>
