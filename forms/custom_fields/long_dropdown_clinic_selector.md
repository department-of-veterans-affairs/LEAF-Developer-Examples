# Extra long list of Clinics in a dropdown

When a list becomes too long to include in a dropdown field, such as a list of clinics, a custom widget may be created.

1. Place the list of clinics in a plain text file, with each clinic on a new line
2. Upload the file into LEAF's File Manager
3. Place the following code in their respective advanced sections, within a "raw_data" input field
4. Update the filename referenced in the code to match the file uploaded

## html
```js
<div id="custom_{{ iID }}">Loading list...</div>
<script>

  $(function(){
    let data = $('#{{ iID }}').val();
    let myFile = "clinics.txt";

    $.ajax({
      type: 'GET',
      url: './files/' + myFile,
      cache: false
    })
      .then(function(res) {
      // split the file into an array
      let lines = res.split("\n").map(v => v.trim());
      let buffer = '<select id="customSelect_{{ iID }}">';
      buffer += '<option value=""></option>';
      
      for(var i in lines) {
        let selected = '';
        if(data.includes(lines[i])) {
          selected = ' selected="selected"';
        }
        buffer += '<option value="'+ lines[i] +'"'+ selected +'>'+ lines[i] +'</option>';
      }
      buffer += '</select>';

      // render the dropdwon
      $('#custom_{{ iID }}').html(buffer);
      
      // apply dropdown style and extra functionality
      $('#customSelect_{{ iID }}').chosen({width: '80%', allow_single_deselect: true});
      $('#customSelect_{{ iID }}').on('change', function() {
        let selected = $('#customSelect_{{ iID }}').val();
        $('#{{ iID }}').val(selected);
      });
    });

  });

</script>
```

## htmlPrint
```js
<span class="printResponse">{{ data }}</span>
```
