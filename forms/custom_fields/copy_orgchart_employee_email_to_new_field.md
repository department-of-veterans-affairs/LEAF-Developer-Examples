# Copy an email from an orgchart_employee selection to a different field

```js
<div id="empSel_{{ iID }}"></div>
<script>

var emailFieldID = 3770;

function renderWidget_{{ iID }}() {
    let empSel = new nationalEmployeeSelector('empSel_{{ iID }}');
    empSel.apiPath = '../orgchart/api/';
    empSel.rootPath = '../orgchart/';
    empSel.setSelectHandler(function(id) {
        $(`#${emailFieldID}`).val(empSel.selectionData[empSel.selection].data[6].data);
    });
    empSel.initialize();
}

if(typeof nationalEmployeeSelector == 'undefined') {
    $('head').append('<link type="text/css" rel="stylesheet" href="../orgchart/css/employeeSelector.css" />');
    $.ajax({
        type: 'GET',
        url: "../orgchart/js/nationalEmployeeSelector.js",
        dataType: 'script',
        success: function() {
            renderWidget_{{ iID }}();
        }
    });
}
else {
    renderWidget_{{ iID }}();
}
  
</script>
```
