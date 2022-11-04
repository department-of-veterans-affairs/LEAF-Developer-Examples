# Copy an email from an orgchart_employee selection to a different field

```js
<div id="empSel_{{ iID }}"></div>
<script>

var emailFieldID = 3770;

$(async function() {
	let empSel = await leaf_employeeSelector[{{ iID }}];
	empSel.setSelectHandler(function(id) {
		$(`#${emailFieldID}`).val(empSel.selectionData[empSel.selection].data[6].data);
  	});
});
  
</script>
```
