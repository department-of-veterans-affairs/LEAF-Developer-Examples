# Copy an email from an orgchart_employee selection to a different field

```js
<script>

var emailFieldID = 3770;

$(async function() {
	let empSel = await leaf_employeeSelector[{{ iID }}];
	empSel.addSelectHandler(function(id) {
		$(`#${emailFieldID}`).val(empSel.selectionData[empSel.selection].data[6].data);
  	});
});
  
</script>
```
