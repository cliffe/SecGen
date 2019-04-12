<?php
  session_start();

  // m'kay
  $drugsarebad = true;
  
  // get the database connection
  require_once("mysql.php");
  // override $drugsarebad and $dead if necessary
  require_once("whoami.php");

  // if drugs are bad then
  // redirect to the home page
  if($drugsarebad) {
    header("Location: ./index.php");
    exit();
  }

  // boolean for task completion
  $done = false;

  // is the target's name present?
  if($_REQUEST['name']) {
    // as well as our assurances
    if($_REQUEST['areyousure'] == 'on'
        && $_REQUEST['areyoureallysure'] == 'on'
        && $_REQUEST['areyoureallyreallysure'] == 'on') {
      // kill them.
      $sql = "UPDATE users SET killed_on = NOW(), killed_by = '" .
      	$_SESSION['user']['id'] . "' WHERE name = '" . mysql_real_escape_string($_REQUEST['name']) . "';";
      mysql_query($sql) and $done = true;
    }
  }

  // get a list of unkilled people
  $sql = "SELECT name, full FROM users WHERE killed_on IS NULL ORDER BY full;";
  $result = mysql_query($sql) or die(mysql_error());
  $users = array(); // populate and array of them
  while($row = mysql_fetch_assoc($result)) {
    $users[] = $row;
  }

  // close the database
  mysql_close($db);
?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Hire a hitman.</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <!-- Le styles -->
    <link href="/css/bootstrap<?php if(!$drugsarebad) echo(".ch"); ?>.min.css" rel="stylesheet">
    <style>
      th { text-align: left; }
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
    <?php require_once("./headnav.php"); ?>
    <div class="container">
      <h1>Hire a Hitman.</h1>
      <?php if(!$done): ?>
        <p>This is no place for children, you'd better be sure that you know what you're doing.</p>
        <p>Who would like to send ... a special message to?</p>
        <form action="#" method="get">
          <select name="name">
            <?php foreach($users as $user): ?>
              <option value="<?php echo(htmlentities($user['name'])); ?>"><?php echo(htmlentities($user['full'])); ?></option>
            <?php endforeach; ?>
          </select>
          <label for"areyousure" class="checkbox">
            Are you sure?
            <input id="areyousure" name="areyousure" type="checkbox" />
          </label>
          <label for"areyoureallysure" class="checkbox">
            Are you really sure?
            <input id="areyoureallysure" name="areyoureallysure" type="checkbox" />
          </label>
          <label for"areyoureallyreallysure" class="checkbox">
            Are you really, really sure?
            <input id="areyoureallyreallysure" name="areyoureallyreallysure" type="checkbox" />
          </label>
          <h3>Payment</h3>
          <p>As you probably know, we know you. We'll call to collect payment. See you soon.</p>
          <div class="form-actions">
            <button type="submit" class="btn btn-primary">Save changes</button>
            <button type="reset" class="btn btn-default">Clear</button>
          </div>
        </form>
      <?php else: ?>
        <p>Let us never speak of it again, well from the point in which I get my money.</p>
      <?php endif; ?>
    </div>
  </body>
</html>
