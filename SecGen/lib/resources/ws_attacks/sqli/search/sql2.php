<?php
	if(!isset($_SESSION['paramatersql2'])){
		$paramater=array("search","lookup","lookingfor", "searched");
		$pickparam=array_rand($paramater);
		$selectedparamsql2=$paramater[$pickparam];
		$_SESSION['paramatersql2'] = $selectedparamsql2;
	}else {
		$selectedparamsql2 = $_SESSION['paramatersql2'];
	}

?>
<p class="text-faded theme">Search our products and services:</p>
<?php
	//form taken from https://www.w3schools.com/php/php_forms.asp and ammended (first form on the page)
	echo '<form  method="POST" action="'.$_SERVER["SCRIPT_NAME"].'" id="searchform">';
	echo '<input  type="text" name="'.$selectedparamsql2.'">';
	echo '<input  type="submit" name="submit" value="Search"></form>';

	if(isset($_POST['submit'])){
	  	$search=htmlspecialchars($_POST[$selectedparamsql2]);
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
