# Check Workflow Alignment
This tool helps reveal potential issues when records have been moved to a different workflow.

Note: This tool is only supported for records that do not have unique parallel workflows, which is the most common configuration.

```html
<style>
#content {
    margin: 1rem;
}
</style>
<h1>Records with potentially incorrect workflows</h1>
<p>This tool helps reveal potential issues when records have been moved to a different workflow. An advanced feature enables admins to change a step to a different workflow. This is useful in certain workflows, but is not a common configuration. Incorrect usage of this feature can cause confusion, as records may be aligned to the wrong workflow.</p>

<h2>Note: This tool is only supported for records that do not have unique parallel workflows, which is the most common configuration.</h2>

<div id="grid"></div>

<script>
async function main() {
    document.querySelector('title').innerText = 'Check Workflows';

    let res = await fetch(`api/workflow/steps`);
    let data = await res.json();

    let stepIDs = {};
    for(let i in data) {
        stepIDs[data[i].stepID] = data[i].workflowID;
    }

    res = await fetch(`api/formStack/categoryList`);
    data = await res.json();

    let categoryIDs = {};
    for(let i in data) {
        categoryIDs[data[i].categoryID] = data[i].workflowID;
    }
	
    let query = new LeafFormQuery();
    //,"joins":["service","categoryName","status"]
    query.addTerm('stepID', '!=', 'resolved');
    query.addTerm('deleted', '=', 0);
    query.join('categoryName');
    query.join('status');
    
    query.onProgress(progress => {
    	document.querySelector('#grid').innerText = `Scanning ${progress} records...`;
    });
    let records = await query.execute();

    let output = {};
    for(let i in records) {
        let stepID = records[i].stepID;
        let categoryID = records[i].categoryIDs?.[0];
        if(categoryID == undefined) {
            output[i] = records[i];
            output[i].issue = 'Error: Form was deleted?';
        }
        
        // the workflow ID should be the same
        if(stepIDs[stepID] != categoryIDs[categoryID]) {
            if(output[i] != undefined) {
                output[i].issue = output[i].desc + ' Wrong workflow?';
            }
            else {
                output[i] = records[i];
                output[i].issue = 'Error: Wrong workflow?';
            }
        }
    }
    
    let grid = new LeafFormGrid('grid');
    grid.enableToolbar();
    grid.setData(Object.keys(output).map(key => output[key]));
    grid.setDataBlob(output);
    
	grid.setHeaders([
        {name: 'Date Initiated', indicatorID: 'dateInitiated', editable: false, callback: function(data, blob) {
            let date = new Date(blob[data.recordID].date * 1000);
            $('#'+data.cellContainerID).html(date.toLocaleDateString().replace(/[^ -~]/g,'')); // IE11 encoding workaround: need regex replacement
        }},
        {name: 'Issue', indicatorID: 'issue', editable: false, callback: function(data, blob) { // The Title field is a bit unique, and must be implemnted this way
            $('#'+data.cellContainerID).html(blob[data.recordID].issue);
        }}
    ]);
    
    grid.renderBody();
}

document.addEventListener('DOMContentLoaded', main);
</script>
```
