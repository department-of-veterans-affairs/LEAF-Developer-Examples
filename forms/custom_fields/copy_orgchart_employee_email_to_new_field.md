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
## Notes
The `6` in `...data[6].data` refers to the ID number of the email attribute.

Other attributes may be referenced by using the relevant ID. The full list of IDs are located here, for rows where `employee` is set: https://github.com/department-of-veterans-affairs/LEAF/blob/master/docker/mysql/db/boilerplate/orgchart_boilerplate_empty.sql#L210-L238
