This is an example of a custom grid input widget, using the "raw_data" input format.

Notes:
- The "html" section is rendered in areas where the user is expected to input data
- The "htmlPrint" section is rendered in areas where the user is expected to view data

### "html" section
```html
<form id="cForm_{{ iID }}">
<table class="table">
  <thead>
    <tr>
      <td>Day</td>
      <td>Start Time</td>
      <td>End Time</td>
      <td>&nbsp;</td>
    </tr>
  </thead>
  <tbody id="tbody_{{ iID }}">
  </tbody>
</table>
</form>
<button id="cButton_{{ iID }}_add">Add Row</button>

<script>

function cFunc_{{ iID }}_updateData() {
    var data = $('#cForm_{{ iID }}').serializeArray();
    $('#{{ iID }}').val(JSON.stringify(data)); // We're storing user data as JSON formatted text into the database
}

function cFunc_{{ iID }}_createRow(index) {
      $('#tbody_{{ iID }}').append('<tr id="cRow_{{ iID }}'+ index +'">'
                             + '<td><select name="cData_{{ iID }}_day'+ index +'"><option>Monday</option><option>Tuesday</option><option>Wednesday</option><option>Thursday</option><option>Friday</option></select></td>'
                             + '<td><input type="text" name="cData_{{ iID }}_startTime'+ index +'"></input></td>'
                             + '<td><input type="text" name="cData_{{ iID }}_endTime'+ index +'"></input></td>'
                             + '<td><img onclick="$(\'#cRow_{{ iID }}'+ index +'\').remove(); cFunc_{{ iID }}_updateData();" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></td>'
                             + '</tr>');
}

$(function() {

  var index = 0;
  var numColumns = 3;
  $('#cButton_{{ iID }}_add').on('click', function() {
      cFunc_{{ iID }}_createRow(index);
       index++;
  });

  $('#cForm_{{ iID }}').on('change', function() {
	cFunc_{{ iID }}_updateData();
  });
  
  var data = JSON.parse($('#{{ iID }}').val()); // Read stored JSON formatted text from the database

  for(var i = 0; i < data.length; i += numColumns) {
    cFunc_{{ iID }}_createRow(index);
    $('select[name=cData_{{ iID }}_day' + index + ']').val(data[i].value);
    $('input[name=cData_{{ iID }}_startTime' + index + ']').val(data[i + 1].value);
    $('input[name=cData_{{ iID }}_endTime' + index + ']').val(data[i + 2].value);
    index++;
  }

});

</script>
```

### "htmlPrint" section
```html
<table class="table">
  <thead>
    <tr>
      <td>Day</td>
      <td>Start Time</td>
      <td>End Time</td>
    </tr>
  </thead>
  <tbody id="print_tbody_{{ iID }}">
  </tbody>
</table>

<script>

$(function() {

  var index = 0;
  var numColumns = 3;
  
function cFunc_{{ iID }}_createRow(index) {
      $('#print_tbody_{{ iID }}').append('<tr id="cRow_{{ iID }}'+ index +'">'
                             + '<td id="cData_{{ iID }}_day'+ index +'"></td>'
                             + '<td id="cData_{{ iID }}_startTime'+ index +'"></td>'
                             + '<td id="cData_{{ iID }}_endTime'+ index +'"></td>'
                             + '</tr>');
}

  if($('#data_{{ iID }}_1').html() == '') {
    return 0;
  }
  var data = JSON.parse($('#data_{{ iID }}_1').html());

  for(var i = 0; i < data.length; i += numColumns) {
    var tIdx = index + 'print';
    cFunc_{{ iID }}_createRow(tIdx);
    $('#cData_{{ iID }}_day' + tIdx).html(data[i].value);
    $('#cData_{{ iID }}_startTime' + tIdx).html(data[i + 1].value);
    $('#cData_{{ iID }}_endTime' + tIdx).html(data[i + 2].value);
    index++;
  }

});

</script>
```
