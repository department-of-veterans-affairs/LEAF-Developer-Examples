<script src="./js/nationalEmployeeSelector.js"></script>
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<style>
    @import "./css/employeeSelector.css"
</style>
    <div id="employee">
        <div id="employeeHeader">
            <span id="employeeName">Employee Search:</span>
        </div>
        <div id="employeeBody">
                <div id="employeeSelector"></div>
        </div>
    </div>


<div id="orgchartForm"></div>
<!--{include file="site_elements/generic_xhrDialog.tpl"}-->

<script type="text/javascript">
/* <![CDATA[ */

var empSel;
var intval;
$(function() {
    empSel = new nationalEmployeeSelector('employeeSelector');
    empSel.initialize();
    empSel.enableNoLimit();

    empSel.setSelectHandler(function() {
        window.location = '?a=view_employee&empUID=' + empSel.selection;
    });
});

/* ]]> */
</script>
