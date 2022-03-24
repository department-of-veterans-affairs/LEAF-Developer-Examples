<script type="text/javascript">

/*

This JavaScript code pre-selects a form for the user, skipping the first page in a normal "New Request" procedure.

*/

$(function() {
    $.ajax({
    	type: 'POST',
        url: './api/?a=form/new',
        dataType: 'json',
        data: {service: '', // Either a service ID # or leave blank
                  title: 'New Request', // Arbitrary title for the request
                  priority: 0,
                  numform_68e7f: 1, // Form ID is listed in the form editor
                  CSRFToken: '<!--{$CSRFToken}-->',
                  123: 'Prefilled data', // This prefills data for indicator ID# 123
        },
        success: function(response) {
        	var recordID = parseFloat(response);
        	if(!isNaN(recordID) && isFinite(recordID) && recordID != 0) {
        		window.location = 'index.php?a=view&recordID=' + recordID;
        	}
        	else {
        		alert(response + '\n\nPlease contact your system administrator.');
        	}
        },
        cache: false
    });
});

</script>
