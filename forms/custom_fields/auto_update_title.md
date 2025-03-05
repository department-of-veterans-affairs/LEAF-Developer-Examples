# Automatically update title

This example appends the name of the form to the end of the current record's title.

## Setup
1. Navigate to your form in the Form Editor
2. Create a new field in Section 1 with the `Raw Data` input format
3. Open the field's "Programmer" mode, and place the following code in the `html` section:

```html
<script src="js/formQuery.js"></script>
<script>
async function main{{ iID }}() {
    // Hide this field's label
    document.querySelector('#format_label_{{ iID }}').style.display = 'none';
  
    // Retrieve record's title and form type(s)
    let recordID = {{ recordID }};
    let query = new LeafFormQuery();
    query.addTerm('recordID', '=', recordID);
    query.join('categoryName');
    query.setExtraParams('&x-filterData=title,categoryNames');
    let data = await query.execute();
  
    // Append the form type to the title, only if it's not already there
    let originalTitle = data[recordID].title;
    let firstFormType = data[recordID].categoryNames[0];
    if(originalTitle.indexOf(firstFormType) != -1) {
        let postData = new FormData();
        postData.append('CSRFToken', CSRFToken);
        postData.append('title', `${originalTitle} - ${firstFormType}`);
        fetch(`api/form/${recordID}/title`, {
            method: 'POST',
            body: postData
        });
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
