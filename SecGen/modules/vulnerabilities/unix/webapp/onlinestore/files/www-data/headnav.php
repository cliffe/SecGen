    <div class="navbar navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <!-- .btn-navbar is used as the toggle for collapsed navbar content -->
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>

          <?php if(isset($drugsarebad) and !$drugsarebad): ?>
            <a class="brand" href="/index.php">the cotton highway</a>
          <?php else: ?>
            <a class="brand" href="/index.php">furniture</a>
          <?php endif ?>

          <div class="nav-collapse collapse navbar-responsive-collapse">
            <ul class="nav">
              <?php if(!$dead): ?>
                <li><a href="/index.php">Home</a></li>
                <li><a href="/product.php">Products</a></li>
  
                <?php if(!($_SESSION and array_key_exists("user", $_SESSION))): ?>
                  <li><a href="/signin.php">Sign In</a></li>
                  <li><a href="/signup.php">Sign Up</a></li>
                <?php else: ?>
                  <!--<li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false">Dropdown <span class="caret"></span></a>
                    <ul class="dropdown-menu" role="menu">
                      <a href="/u/index.php">My Account <small>(<?php echo($_SESSION['user']['name']); ?>)</small></a>
                    </ul>
                  </li>-->
                  <li><a href="/basket.php">Basket</a></li>
                  <li><a href="/signout.php">Sign Out</a></li>
                <?php endif ?>
              <?php else: ?>
                <li><a href="/signout.php">Sign Out</a></li>
              <?php endif ?>

              <?php if(!$dead): ?>
                <?php if(isset($drugsarebad) and !$drugsarebad): ?>
                  <!--<li><a href="/admin/index.php">Admin</a></li>-->
                <?php endif; ?>
                <li><a href="/contact.php">Contact</a></li>
              <?php endif ?>
            </ul>
            <?php if($_SESSION and array_key_exists("user", $_SESSION)): ?>
              <ul class="nav pull-right">
                <li class="dropdown">
                  <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                    <?php echo($_SESSION['user']['full']); ?>
                    <b class="caret"></b>
                  </a>
                  <?php if(!$dead): ?>
                  <ul class="dropdown-menu">
                    <li><a href="/u/index.php">My Account</a></li>
                    <?php if(isset($drugsarebad) and !$drugsarebad): ?>
                      <li><a href="/admin/index.php">Admin</a></li>
                    <?php else: ?>
                      <!--<li><a href="/admin/index.php">Admin</a></li>-->
                    <?php endif; ?>
                  </ul>
                  <?php endif; ?>
                </li>
              </ul>
            <?php endif; ?>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>
    <script src="/js/jquery-2.1.2.min.js"></script>
    <script src="/js/bootstrap.min.js"></script>
