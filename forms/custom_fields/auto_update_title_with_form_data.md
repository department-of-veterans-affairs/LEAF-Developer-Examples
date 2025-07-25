# Automatically update title (form data)

This example replaces the current record's title with form data.

## Setup
1. Navigate to your form in the Form Editor.
2. Create a new field in Section 1 with the `Raw Data` input format.
3. Open the field's "Programmer" mode, and place the following code in the `html` section.
4. Modify the code (dataFieldIDs and getCustomTitle) to match your data field IDs and desired format.

Note: If the data fields are all in the same section, place the code in the same section. If the fields are in different sections, place the code in a section that comes after all data fields.

```html
<script src="js/formQuery.js"></script>
<script>
async function main{{ iID }}() {
    let dataFieldIDs = [1, 2, 3];

    let data = {}; // This is populated automatically

    function getCustomTitle() {
        return `My Custom Title ${data[1]} ${data[2]} ${data[3]}`;
    }

    async function saveTitle() {
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

    if(sameSection) {
        // Retrieve data within the same section
        form.addPostModifyCallback(saveTitle);
    } else {
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
