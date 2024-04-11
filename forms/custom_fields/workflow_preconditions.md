# Workflow Preconditions

Additional logic can be added as prerequisites for workflow actions, by encoding the logic in a form field.

This can be useful if, for example:
- Workflow actions need to be restricted in certain conditions
- Data needs to be automatically calculated during a workflow action

## Prerequisites:
- The form field containing logic must be included as an Inline Form Field in the workflow step where you want the logic to be processed.

## Example:
```html
<script>

/*   Set up a precondition for a workflow action
 *   data - Object:{
 *             idx: index matching the current action for data.step.dependencyActions[]
 *             step: data related to the current step. See ./api/formWorkflow/[recordID]/currentStep
 *          }
 *   completeAction - Function: Must be executed in order to complete the workflow action
 */
workflow.setActionPreconditionFunc((data, completeAction) => {

    // This will calculate a date, writing it to field ID 123 only if the user clicks on a button with actionType: "sign"
    if(data.step.dependencyActions[data.idx].actionType == 'sign') {

      	let newDate = new Date();
        newDate.setDate(newDate.getDate() + 365);
        let output = `${newDate.getUTCMonth() + 1}/${newDate.getUTCDate()}/${newDate.getUTCFullYear()}`;

        document.getElementById('123').value = output;
    }

    completeAction();

});

</script>
```
