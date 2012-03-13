jQuery(function(){
	jQuery(".pagination a").live("click", function(){
		Element.show('spinner');
		jQuery.get(this.href, null, null, "script");
		return false;
	});
});
