# Workflow: Run a function after an action has been taken

Additional logic can be added after a workflow action has be succesfully taken.

This can be useful if, for example:
- You want to run a function after confirming an approval

## Prerequisites:
- The form field containing logic must be included as an Inline Form Field in the workflow step where you want the logic to be processed.

## Example:
```html
<script>

/*   Run a function after a specific workflow action has been confirmed
 *   data - Object:{
 *                 actionType: the action type that was exectued
 *                 dependencyID: the dependencyID associated with the action
 *                 comment: the comment associated with the action
 *          }
 */
workflow.setActionSuccessCallback(async (data) => {

  // After an approval action has been confirmed, this will create a new record and store cross references of the record IDs.
  if(data.actionType != 'approval') {
    return;
  }

  let currentRecordID = {{ recordID }};

  // Create a new record
  let formData = new FormData();
  formData.append('CSRFToken', CSRFToken);
  formData.append('numform_5ea07', 1);
  formData.append('3', currentRecordID);

  let newRecordID = await fetch(`./api/form/new`, {
                            method: 'POST',
                            body: formData
                          }).then(res => res.text());

  // Update the current record with a reference to the new ID
  let formData = new FormData();
  formData.append('CSRFToken', CSRFToken);
  formData.append('4', newRecordID);

  fetch(`./api/form/${currentRecordID}`, {
    method: 'POST',
    body: formData
  }).then(res => res.text());

});

</script>
```
