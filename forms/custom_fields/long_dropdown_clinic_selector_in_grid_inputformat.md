# Extra long list of Clinics in a Grid dropdown

:warning: This customization modifies important templates and will require you to manually update and maintain them.

:warning: The "Grid" input field has not been designed to accomodate customizations, and therefore may be subject to change. You will need to maintain and update this.

When a list becomes too long to include in a dropdown field, such as a list of clinics, a custom widget may be created.

Prerequisites:

1. Edit the subindicators template
2. Find the section containing the "grid" format
3. Within the same section, add the following line at the end:
```
<!--{$indicator.html}-->
```

Setup:

1. Place the list of clinics in a plain text file, with each clinic on a new line
2. Upload the file into LEAF's File Manager
3. Place the following code in their respective advanced sections, within a "Grid" input field
4. Update the filename referenced in the code to match the file uploaded
5. Update the column index referenced in the code to match the position of the column starting with 0 for the left-most column.

## html
```js
<script>

  $(async function() {
    let myFile = "clinics.txt";
    let customColumnIndex = 0;

    // Read file and get existing data
    let results = await Promise.all([
        fetch(`files/${myFile}`).then(res => res.text()),
        fetch(`api/form/{{ recordID }}/rawIndicator/{{ iID }}/1`).then(res => res.json())
    ]);
    let fileContent = results[0];
    let data = results[1];    

    // split the file into an array
    let lines = fileContent.split("\n").map(v => v.trim());

    // Prepare dropdown
    let buffer = '';
    for(var i in lines) {
      buffer += '<option value="'+ lines[i] +'">'+ lines[i] +'</option>';
    }

    // find matching dropdowns
    let rows = document.querySelectorAll('#grid_{{ iID }}_1_input tbody tr');
    rows.forEach(row => {
      let cols = row.querySelectorAll('td');
      
      let dropdown = cols[customColumnIndex].querySelector('select');
      
      // render the dropdwon
      $(dropdown).append(buffer);
    });
    
    // apply existing data
    rows.forEach((row, idx) => {
    	if(data[{{ iID }}].value?.cells[idx][customColumnIndex] != undefined) {
          let cols = row.querySelectorAll('td');
      
          let dropdown = cols[customColumnIndex].querySelector('select');
          
          dropdown.value = data[{{ iID }}].value?.cells[idx][customColumnIndex];
        }
    });
  });

</script>
```
