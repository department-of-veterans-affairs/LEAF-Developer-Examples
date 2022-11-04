# Dropdown options for orgchart_employee fields

This replaces the normal employee search with a dropdown list of employees who are associated with a particular group.

```js
<div id="empDropdown_loadIndicator{{ iID }}"><img src="images/indicator.gif" /> Loading</div>
<select id="empDropdown_{{ iID }}" style="display: none">
    <option val="">Please select an individual...</option>
</select>
<script>
$(function () {
    let groupID = "105";
    
    leaf_employeeSelector[{{ iID }}].then(empSel => {
        empSel.disableSearch();
    });
    
    $('#empDropdown_{{ iID }}').on('change', function() {
        let mySelection = $('#empDropdown_{{ iID }}').val();
        $('#{{ iID }}').val(mySelection);
    });
    $.ajax({
        type: 'GET',
        url: `./api/group/${groupID}/members`,
        success: function(res) {
            $('#empDropdown_{{ iID }}').append('<option value="">Select an option</option>');
            for(let i in res) {
                $('#empDropdown_{{ iID }}').append(`<option value="${res[i].empUID}">${res[i].lastName}, ${res[i].firstName} ${res[i].middleName}</option>`);
            }
            
            if($('#{{ iID }}').val() != '') {
                $('#empDropdown_{{ iID }}').val($('#{{ iID }}').val());
            }
            
            $('#empDropdown_loadIndicator{{ iID }}').css('display', 'none');
            $('#empDropdown_{{ iID }}').css('display', 'inline');
        },
        cache: false
    });
});
</script>
```
