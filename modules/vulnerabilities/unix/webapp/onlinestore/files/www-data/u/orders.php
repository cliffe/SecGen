<?php
  session_start();

  // m'kay
  $drugsarebad = true;
  
  // get the database connection
  require_once("../mysql.php");
  // override $drugsarebad and $dead if necessary
  require_once("../whoami.php");

  // logged in?
  if(!isset($_SESSION['user'])) {
    header("Location: ./index.php");
  }

  // are we looking at a specific order?
  if(isset($_GET['id']) && is_numeric($_GET['id'])) {
    $sql = "SELECT p.*, oi.*, o.*, date_format(o.expire, '%Y-%m') as expire FROM products p INNER JOIN orders_items oi ON p.id = oi.product_id inner join orders o on oi.order_id = o.id WHERE oi.order_id='".$_GET['id']."' and o.user_id=".$_SESSION['user']['id'].";";
  // otherwise summarise it
  } else {
    $sql = "select id, date, (SELECT SUM(price) FROM orders_items oi WHERE oi.order_id = o.id) as total from orders o where o.user_id=" . $_SESSION['user']['id'];
  }

  // get the data
  $result = mysql_query($sql, $db);
  if(!$result)
    die("Query failed: " . mysql_error());

  // order doesn't exist
  if(isset($_GET['id']) && is_numeric($_GET['id']) && mysql_num_rows($result) <= 0) {
    header("Location: /u/orders.php");
  }
 
  $things = array(); // get the think=gs you bought
  while($row = mysql_fetch_assoc($result)) {
    $things[] = $row;
  }

  mysql_close($db);
?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <?php if(isset($_GET['id']) && is_numeric($_GET['id'])) { ?>
      <title>Order #<?php echo(htmlentities($_GET['id'])); ?></title>
    <?php } else { ?>
      <title>Previous Orders</title>
    <?php } ?>
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
    <link rel="stylesheet" type="text/css" href="/css/jquery.dataTables.min.css">
    <style>
      .container, .navbar-fixed-top .container {
        width: 800px; /* 60px to make the container go all the way to the bottom of the topbar */
      }
      <?php if(!(isset($_GET['id']) && is_numeric($_GET['id']))): ?>
      img { max-width: 50px; max-height: 50px; }
      <?php endif; ?>
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
    <?php include("../headnav.php"); ?>
    <div class="container">
      <?php if(isset($_GET['id']) && is_numeric($_GET['id'])) { ?>
        <h1>Order #<?php echo(htmlentities($_GET['id'])); ?></h1>
        <p>Back to <a href="/u/orders.php">order history</a>.</p>
        <table width="100%" class="table table-striped">
          <tbody>
            <tr>
              <td><?php echo("************" . htmlentities(substr($things[0]['cc'], -4))); ?></td>
              <td><?php echo(htmlentities(substr($things[0]['cvv'], 0, 1)) . "**"); ?></td>
              <td><?php echo(htmlentities($things[0]['expire'])); ?></td>
              <td><?php echo(htmlentities($things[0]['outfordelivery'] == false ? "Pending" : "Out for delivery")); ?></td>
            </tr>
          <tbody>
          <thead>
            <tr>
              <th width="25%">Credit Card Number</td>
              <th width="25%">CCV</td>
              <th width="25%">Expiry Date</td>
              <th width="25%">Status</td>
            </tr>
          <thead>
        </table>
      <?php } else { ?>
        <h1>Order History</h1>
      <?php } ?>
      <table width="100%" class="datatable">
        <thead>
          <tr>
          <?php if(isset($_GET['id']) && is_numeric($_GET['id'])) { ?>
            <th width="25%">Product</th>
            <th width="25%">Quantity</th>
            <th width-"25%">Price</th>
            <th width-"25%">Total</th>
          <?php } else { ?>
            <th width="25%">Order Number</th>
            <th width="25%">Date</th>
            <th width-"25%">Price</th>
          <?php } ?>
          </tr>
        </thead>
        <tbody>
          <?php
            $total = 0;
            foreach($things as $thing) { 
              if(isset($_GET['id']) && is_numeric($_GET['id'])) {
                $total += ($thing['price'] * $thing['quantity']);
          ?>
            <tr>
              <td><a href="/product.php?id=<?php echo(htmlentities($thing['product_id'])); ?>"><?php echo(htmlentities($thing['name'])); ?></a></td>
              <td style="text-align: center"><?php echo(htmlentities($thing['quantity'])); ?></td>
              <td style="text-align: right"><?php echo(htmlentities($thing['price'])); ?></td>
              <td style="text-align: right"><?php echo(htmlentities($thing['price'] * $thing['quantity'])); ?></td>
            </tr>
          <?php 
              } else {
          ?>
            <tr>
              <td style="text-align: right"><a href="orders.php?id=<?php echo(htmlentities($thing['id'])); ?>"><?php echo(htmlentities($thing['id'])); ?></a></td>
              <td style="text-align: center"><?php echo(htmlentities($thing['date'])); ?></td>
              <td style="text-align: right"><?php echo(htmlentities($thing['total'])); ?></td>
            </tr>
          <?php
              }
            } 
          ?>
        </tbody>
      <?php if(isset($_GET['id']) && is_numeric($_GET['id'])) { ?>
        <tfoot>
          <td colspan="3">Total</td>
          <td style="text-align: right;"><?php echo(htmlentities($total)); ?></td>
        </tfoot>
      <?php } ?>
      </table>
    </div> <!-- /container -->

    <script type="text/javascript" charset="utf8" src="/js/jquery-2.1.2.min.js"></script>
    <script type="text/javascript" charset="utf8" src="/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript">
      $(document).ready(function() {
        $(".datatable").dataTable({
          "iDisplayLength" : -1,
          "sDom": "t"
        });
      });
    </script>
  </body>
</html>
