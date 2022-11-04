# Dropdown options for orgchart_group fields

This replaces the normal group search with a dropdown list of groups who are associated with a group tag.

Prerequisites:
1. Groups that you wish to include in the dropdown must be tagged with the same identifier.


## html
```js
<div id="groupDropdown_loadIndicator{{ iID }}"><img src="images/indicator.gif" /> Loading</div>
<select id="groupDropdown_{{ iID }}" style="display: none">
</select>
<script>
$(function () {
    var groupTag = "YOUR_GROUP_TAG";

    leaf_groupSelector[{{ iID }}].then(grpSel => {
    	grpSel.disableSearch();
    });
    
    $('#groupDropdown_{{ iID }}').on('change', function() {
    	var mySelection = $('#groupDropdown_{{ iID }}').val();
    	$('#{{ iID }}').val(mySelection);
    });
    $.ajax({
        type: 'GET',
        url: orgchartPath + '/api/group/tag/_' + groupTag,
        success: function(res) {
            $('#groupDropdown_{{ iID }}').append('<option value="">Select an option</option>');
            for(var i in res) {
                $('#groupDropdown_{{ iID }}').append('<option value="' + res[i].groupID + '">' + res[i].groupTitle + '</option>');
            }
            
            if($('#{{ iID }}').val() != '') {
                $('#groupDropdown_{{ iID }}').val($('#{{ iID }}').val());
            }
            
            $('#groupDropdown_loadIndicator{{ iID }}').css('display', 'none');
            $('#groupDropdown_{{ iID }}').css('display', 'inline');
        }
    });
});
</script>
```
