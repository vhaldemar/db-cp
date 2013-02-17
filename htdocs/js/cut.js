jQuery(document).ready(function(){
	jQuery('.cat_link').click(function(){
		jQuery(this).parent().children('div.cat_cont').toggle('normal');
			return false;
     });
});
