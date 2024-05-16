# Copy an email from an orgchart_employee selection to a different field

## Prerequisite
- Destination text field to hold the email

Change 3770 to the ID for the destination text field.

```js
<script>

$(async function() {
	var emailFieldID = 3770;

	let empSel = await leaf_employeeSelector[{{ iID }}];
	empSel.addSelectHandler(function(id) {
		$(`#${emailFieldID}`).val(empSel.selectionData[empSel.selection].data[6].data);
  	});
});
  
</script>
```
