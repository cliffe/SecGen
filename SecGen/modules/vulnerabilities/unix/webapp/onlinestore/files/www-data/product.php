<?php
  session_start();

  // m'kay
  $drugsarebad = true;
  
  // get the database connection
  require_once("mysql.php");
  // override $drugsarebad and $dead if necessary
  require_once("whoami.php");

  // do we have an id? and is it numeric?
  if(isset($_GET['id']) && !is_numeric($_GET['id'])) {
    header("Location: ./index.php"); // no> then go home
    exit();
  }

  // if we have been given a quantity
  if(isset($_REQUEST['quantity']) && is_numeric($_REQUEST['quantity'])) {
    // add the item to the basket
    $sql = "insert into basket (user_id, product_id, quantity) values('" . 
      mysql_real_escape_string($_SESSION['user']['id']) . "', '" .
      mysql_real_escape_string($_GET['id']) . "', " .
      mysql_real_escape_string($_REQUEST['quantity']) . ") on duplicate key update quantity = quantity + " .
      mysql_real_escape_string($_REQUEST['quantity']) . ";";
    $result = mysql_query($sql, $db);
    if($result) {
      header("Location: /basket.php");
      exit();
    }
  }

  // some sneaky sql ...
  if($drugsarebad) {
    $sql = "SELECT p.* FROM products p WHERE danger=false";
  } else {
    $sql = "SELECT p.* FROM products p WHERE danger=true";
  }

  // are we looking at anything in particular?
  if(isset($_GET['id'])) {
    // request only the product
    $sql .= " AND p.id=".mysql_real_escape_string($_GET['id']);
  // are we searching?
  } else if(isset($_GET['filter']) and !empty($_GET['filter'])) {
    // report only those that are similar
    $sql .= " AND p.name LIKE '%%" . $_GET['filter'] . "%%'";
  }

  // get whatever we were looking for
  $result = mysql_query($sql, $db);
  if(!$result)
    die("Query failed: " . mysql_error());

  $products = array(); // make them into an array
  while($row = mysql_fetch_assoc($result)) {
    $products[] = $row;
  }

  // clean up
  mysql_close($db);
?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <?php if(!isset($_GET['id'])) { ?>
      <title>Our products</title>
    <?php } else { ?>
      <title><?php echo($products[0]['name']); ?></title>
    <?php } ?>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <!-- Le styles -->
    <link href="/css/bootstrap<?php if(!$drugsarebad) echo(".ch"); ?>.min.css" rel="stylesheet">
    <style>
      th { text-align: left; }
      <?php if(!$_GET['id']): ?>
      img { max-width: 50px; max-height: 50px; }
      <?php endif; ?>
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
      <h1>
        <?php if(isset($_GET['id'])) { ?>
          <?php echo(htmlentities($products[0]['name'])); ?>
        <?php } else { ?>
          Products
        <?php } ?>
      </h1>
      <?php if(!isset($_GET['id'])) { ?>
        <p style="margin-bottom: 20px;">Here is our latest range.</p>
        <form action="#" method="get" class="form-inline">
          <div class="input-append">
            <span class="add-on">Filter Results:</span>
            <input type="text" id="filter" name="filter" 
              <?php if(isset($_GET['filter'])) echo "value=\"" . htmlentities($_GET['filter']) . "\""; ?>
             />
            <button type="submit" class="btn btn-default">Submit</button>
          </div>
        </form>
        <table class="datatable">
          <thead>
            <th></th>
            <th>Name</th>
            <th>Description</th>
            <th>Price</th>
          </thead>
          <?php if(count($products) > 0): ?>
            <tbody>
              <?php foreach($products as $product): ?>
                <tr>
                  <td><a href="./product.php?id=<?php echo(htmlentities($product["id"])); ?>"><img style="max-height: 150px;" src="<?php echo($product['image']); ?>" /></a></td>
                  <td><a href="./product.php?id=<?php echo(htmlentities($product['id'])); ?>"><?php echo(htmlentities($product['name'])); ?></a></td>
                  <td><?php echo(htmlentities($product['description'])); ?></td>
                  <td>£<?php echo($product['price']); ?></td>
                </tr>
              <?php endforeach; ?>
            </tbody>
          <?php endif; ?>
        </table>
      <?php } else { ?>
        <br />
        <?php if(isset($_SESSION['user'])): ?>
          <form action="#" method="post" class="span3" style="float: right;">
            <fieldset>
              <legend>Add to basket</legend>
              Price: £<?php echo($products[0]['price']); ?>
              <label>Quantity</label>
              <input name="quantity" type="number" placeholder="How many..." />
              <div class="form-actions">
                <button type="submit" class="btn btn-primary">Send</button>
                <button type="reset" class="btn">Clear</button>
              </div>
            </fieldset>
          </form>
        <?php endif; ?>
        <p class="pull-right"><a href="./product.php"><small>Back to listing</small></a></p>
        <img src="<?php echo($products[0]['image']); ?>" alt="<?php echo(htmlentities($products[0]['name'])); ?>" class="span7" /><br />
        <hr style="clear: both" />
        <h2>Description</h2>
        <p><?php echo(htmlentities($products[0]['description'])); ?></p>
      <?php } ?>
    </div> <!-- /container -->

    <script type="text/javascript" charset="utf8" src="/js/jquery-2.1.2.min.js"></script>
    <script type="text/javascript" charset="utf8" src="/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript">
      $(document).ready(function() {
        $(".datatable").dataTable({
          "dom": "tip"
        });
        $("input[name='quantity']").change(function() {
          if($(this).val() < 0) {
            $(this).val(0);
            alert("Quantity must be a positive number.");
          }
        });
      });
    </script>
  </body>
</html>
