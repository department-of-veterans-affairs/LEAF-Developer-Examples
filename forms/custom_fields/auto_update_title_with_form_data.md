# Automatically update title (form data)

This example replaces the current record's title with form data.

## Setup
1. Navigate to your form in the Form Editor.
2. Create a new field in Section 1 with the `Raw Data` input format.
3. Open the field's "Programmer" mode, and place the following code in the `html` section.
4. Modify the code to match your data field IDs and desired format.

```html
<script src="js/formQuery.js"></script>
<script>
async function main{{ iID }}() {
    let dataFieldIDs = [1];

    function getCustomTitle() {
        return `My Custom Title ${data[1]} ${data[2]} ${data[3]}`;
    }

    function saveTitle() {
        let postData = new FormData();
        postData.append('CSRFToken', CSRFToken);
        postData.append('title', getCustomTitle());
        fetch(`api/form/${recordID}/title`, {
            method: 'POST',
            body: postData
        });
    }

    // Hide this field's label
    document.querySelector('#format_label_{{ iID }}').style.display = 'none';
    
    // Determine location of data
    let sameSection = true;
    dataFieldIDs.forEach(id => {
        if(document.getElementById(id) == undefined) {
            sameSection = false;
            return;
        }
    });

    let data = {};
    if(sameSection) {
        // Retrieve data within the same section
        dataFieldIDs.forEach(id => {
            document.getElementById(id).addEventListener('change', () => {
            	dataFieldIDs.forEach(id => {
                    data[id] = document.getElementById(id).value;
                });
                saveTitle();
            });
        });

        
    } else {
        // Retrieve data from other sections
        let recordID = {{ recordID }};
        let query = new LeafFormQuery();
        query.addTerm('recordID', '=', recordID);
        query.getData(dataFieldIDs);
        query.setExtraParams('&x-filterData=');
        let res = await query.execute();
        dataFieldIDs.forEach(id => {
            let value = res[recordID].s1[`id${id}`];
            if(value != undefined) {
                data[id] = value;
            } else {
                data[id] = '';
            }
        });
  
        saveTitle();
    }
}

// Wait for the page to fully load before running our function
if(document.readyState !== 'loading') {
    main{{ iID }}();
} else {
    document.addEventListener('DOMContentLoaded', main{{ iID }});
}
</script>
```
