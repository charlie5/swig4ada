<?php
// Sample test file

require "tests.php4";
require "class_ignore.php";

check::functions(array(do_blah,new_bar,bar_blah,new_boo,boo_away,new_far,new_hoo));
check::classes(array(class_ignore,Bar,Boo,Far,Hoo));
// No new vars
check::globals(array());

$bar=new bar();
do_blah($bar);
check::classparent($bar,"");

check::done();
?>
