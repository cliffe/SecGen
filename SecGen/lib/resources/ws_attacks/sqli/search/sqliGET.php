<p class="text-faded theme">Search our site:</p>

<?php

	if(!isset($_SESSION['paramater1sqlget'])){
		$paramater1=array("search","lookup","lookingfor", "searched");
		$pickparam1=array_rand($paramater1);
		$selectedparam1sqlget=$paramater1[$pickparam1];
		$_SESSION['paramater1sqlget'] = $selectedparam1sqlget;
	}else {
		$selectedparam1sqlget = $_SESSION['paramater1sqlget'];
	}

	//form taken from https://www.w3schools.com/php/php_forms.asp and ammended (first form on the page)
	echo '<form  method="GET" action="'.$_SERVER["SCRIPT_NAME"].'" class="text-faded theme" id="searchform">';
	echo '<input  type="text" name="'.$selectedparam1sqlget.'">';
	echo '<input  type="submit" name="submit" value="Search"></form> ';

	if(isset($_GET['submit'])){
	  $search=htmlspecialchars($_GET[$selectedparam1sqlget]);
	  $statement="SELECT * FROM Products WHERE name LIKE '%" .$search ."%'";
	  $result=mysqli_query($conn2, $statement);
	  while ($row=mysqli_fetch_assoc($result)){
			?>
			<div class="product_holder">
				<img src="<?php echo $row['img'];?>.jpg" height="128px" width="128px" />
				<div class="txt_holder">
					<?php echo $row['name'];?>
				</div>
			</div>
			<?php
	  }
	}
?>
