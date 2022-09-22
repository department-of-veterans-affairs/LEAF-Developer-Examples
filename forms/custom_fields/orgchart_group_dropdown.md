# Dropdown options for orgchart_group fields

This replaces the normal group search with a dropdown list of groups who are associated with a group tag.

Prerequisites:
1. Input format must be set to "raw_data".

Known issues:
1. Orgchart path is hardcoded
2. Alert for required field is not triggered. However the restriction to submit an incomplete request is still in place.


## html
```js
<div id="groupDropdown_loadIndicator{{ iID }}"><img src="images/indicator.gif" /> Loading</div>
<select id="groupDropdown_{{ iID }}" style="display: none">
    <option val="">Please select a group...</option>
</select>
<script>
$(function () {
    var groupTag = "Academy_Demo1";
    
    $('#grpSel_{{ iID }}').css('display', 'none');
    
    $('#groupDropdown_{{ iID }}').on('change', function() {
    	var mySelection = $('#groupDropdown_{{ iID }}').val();
    	$('#{{ iID }}').val(mySelection);
    });
    $.ajax({
        type: 'GET',
        url: orgchartPath + '/api/group/tag/_' + groupTag,
        success: function(res) {
            for(var i in res) {
                $('#groupDropdown_{{ iID }}').append('<option value="' + res[i].groupID + '">' + res[i].groupTitle + '</option>');
            }
            
            if($('#{{ iID }}').val() != '') {
                $('#groupDropdown_{{ iID }}').val($('#{{ iID }}').val());
            }
            
            $('#groupDropdown_loadIndicator{{ iID }}').css('display', 'none');
            $('#groupDropdown_{{ iID }}').css('display', 'inline');
        },
        cache: false
    });
});
</script>
```

## htmlPrint
```js
<span id="group_{{ iID }}" class="printResponse"></span>
<script>
$(function() {
  	$.ajax({
    	type: 'GET',
      	url: '../orgchart/api/group/{{ data }}',
    }).then(res => {
    	if(res.title != undefined) {
          $('#group_{{ iID }}').html(res.title);
        }
    });
});
</script>
```
