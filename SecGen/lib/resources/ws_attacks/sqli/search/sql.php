
<h2 class="section-heading theme">Search</h2>
<hr class="mb-4">

<?php
if(!isset($_SESSION['paramater'])){
	$paramater=array("search","lookup","lookingfor", "searched");
	$pickparam=array_rand($paramater);
	$selectedparam=$paramater[$pickparam];
	$_SESSION['paramater'] = $selectedparam;
}else {
	$selectedparam = $_SESSION['paramater'];
}

echo '<p class="text-faded theme">Search our site to find what you are looking for:</p>';
//form taken from https://www.w3schools.com/php/php_forms.asp and ammended (first form on the page)
echo '<form  method="POST" action="'.$_SERVER["SCRIPT_NAME"].'" id="searchform" class="theme">';
echo '<input  type="text" name="'.$selectedparam.'">';
echo '<input  type="submit" name="submit" value="Search"></form> ';

if(isset($_POST['submit'])){
  	$search=htmlspecialchars($_POST[$selectedparam]);
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
<br>
<br>
<br>
