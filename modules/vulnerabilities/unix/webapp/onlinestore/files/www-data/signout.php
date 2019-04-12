<?php
  session_start();
  session_destroy();
  session_regenerate_id();

  // remove site cookies (session cookie is deleted by session_destroy() 
  setcookie("040ec1ee950ffc53291f6df0ffc30325", 0, time() - 3600, '/', null, false, false);
  setcookie("basket", "", time() - 3600, '/', null, false, false);

  // go home
  header("Location: /index.php");
?>
