<?php
  session_start();

  // m'kay
  $drugsarebad = true;
  
  // get the database connection
  require_once("mysql.php");
  // override $drugsarebad and $dead if necessary
  require_once("whoami.php");

  // are we logged in?
  if(!isset($_SESSION['user'])) {
    header("Location: ./index.php");
  }

  // have we got a basket cookie?
  if(!isset($_COOKIE['basket'])) {
    setcookie("basket", $_SESSION['user']['id'], 0, '/', null, false, false);
    $_COOKIE['basket'] = $_SESSION['user']['id'];
  }

  // is it a pos request?
  if(isset($_POST['empty']) && $_POST['empty'] == true) {
    // empty the basket (uses a stored procedure)
    $sql = sprintf("CALL empty(%d);", $_SESSION['user']['id']);
    $result = mysql_query($sql);
    if(!$result)
      die("Query failed: " . mysql_error());
  }

  $nocc = $nocvv = $noexp = false;
  // are we going to buy the basket?
  if(isset($_POST['buy']) && $_POST['buy'] == true) {
    // any cc number?
    if(!isset($_POST['cc']) || !preg_match("/^[0-9]{16}$/", $_POST['cc']))
      $nocc = true;

    // any ccv?
    if(!isset($_POST['cvv']) || !preg_match("/^[0-9]{3}$/", $_POST['cvv'])) 
      $nocvv = true;

    // any expiry date?
    if(!isset($_POST['expire']) || !preg_match("/^[0-9]{4}-[0-9]{2}$/", $_POST['expire']))
      $noexp = true;

    // do we have everything?
    if($noexp === false && $nocc === false && $nocvv === false) {
      // buy the basket (using a stored procedure)
      $sql = sprintf("CALL buy(%d, '%s', '%s', str_to_date('%s', '%%Y-%%m'));",
          $_SESSION['user']['id'],
          mysql_real_escape_string($_POST['cc']),
          mysql_real_escape_string($_POST['cvv']),
          mysql_real_escape_string($_POST['expire'])
        );
      $result = mysql_query($sql);
      if(!$result)
        die("Query failed: " . mysql_error());
      $row = mysql_fetch_assoc($result);
      // redirect to the orders page
      header("Location: /u/orders.php?id=" . $row['order_id']);
      die();
    }
  }

  // get a list of products in the users basked
  $sql = sprintf("SELECT p.*, b.quantity FROM products p INNER JOIN basket b ON p.id = b.product_id WHERE b.user_id='%s';", $_COOKIE['basket']);

  $result = mysql_query($sql, $db);
  if(!$result)
    die("Query failed: " . mysql_error());

  $products = array(); // create an array of them
  while($row = mysql_fetch_assoc($result)) {
    $products[] = $row;
  }

  mysql_close($db);
?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Your Basket</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <!-- Le styles -->
    <link href="/css/bootstrap<?php if(!$drugsarebad) echo(".ch"); ?>.min.css" rel="stylesheet">
    <style>
      img { max-width: 50px; max-height: 50px; }
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
      <h1>Basket</h1>
      <table width="100%" class="datatable">
        <thead>
          <tr>
            <th width="5%"></th>
            <th width="75%" class="align-right">Name</th>
            <th width="10%">Quantity</th>
            <th width-"10%">Price</th>
          </tr>
        </thead>
        <tbody>
          <?php
            $total = 0;
            foreach($products as $product) { 
              $total += ($product['price'] * $product['quantity']);
          ?>
            <tr>
              <td><a href="./product.php?id=<?php echo(htmlentities($product['id'])); ?>"><img src="<?php echo(htmlentities($product['image'])); ?>" /></a></td>
              <td><a href="./product.php?id=<?php echo(htmlentities($product['id'])); ?>"><?php echo(htmlentities($product['name'])); ?></a></td>
              <td><?php echo(htmlentities($product['quantity'])); ?></td>
              <td>£<?php echo(htmlentities($product['price'])); ?></td>
            </tr>
          <?php } ?>
        </tbody>
        <tfoot>
          <td colspan="2">Total</td>
          <td><?php echo(htmlentities($total)); ?></td>
        </tfoot>
      </table>
      <?php if(sizeof($products) > 0): ?>
      <br />
      <br />
      <form action="#" method="post">
        <fieldset>
          <legend>Checkout</legend>
          <label>Credit Card Number</label>
          <?php if($nocc): ?>
            <div class="control-group error">
          <?php endif; ?>
              <input type="text" value="" name="cc" />
          <?php if($nocc): ?>
              <span class="help-inline">This is not a valid credit card number (16 digits).</span>
            <div>
          <?php endif; ?>
          <label>Expiry Date (YYYY-MM)</label>
          <?php if($noexp): ?>
            <div class="control-group error">
          <?php endif; ?>
              <input type="text" value="" name="expire" />
          <?php if($noexp): ?>
              <span class="help-inline">This is not a valid expiry date (YYYY-MM).</span>
            </div>
          <?php endif; ?>
          <label>Card Verification Value (CVV on the back of your card)</label>
          <?php if($nocvv): ?>
            <div class="control-group error">
          <?php endif; ?>
              <input type="number" value="" name="cvv" max="999" min="0" />
          <?php if($nocvv): ?>
              <span class="help-inline">This is not a valid CVV (000-999).</span>
            </div>
          <?php endif; ?>
          <div class="form-actions">
            <button type="submit" name="buy" value="true" class="btn btn-primary">Buy</button>
            <button type="submit" name="empty" value="true" class="btn">Empty</button>
          </div>
        </fieldset>
      </form>
      <?php endif; ?>
    </div> <!-- /container -->

    <script type="text/javascript" charset="utf8" src="/js/jquery-2.1.2.min.js"></script>
    <script type="text/javascript" charset="utf8" src="/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript">
      $(document).ready(function() {
        $(".datatable").dataTable({
          "iDisplayLength" : -1
        });
      });
    </script>
  </body>
</html>
