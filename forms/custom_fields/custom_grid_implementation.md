This is an example implementation of a custom grid input widget, using the "raw_data" input format.

Notes:
- The "html" section is rendered in areas where the user is expected to input data
- The "htmlPrint" section is rendered in areas where the user is expected to view data

### "html" section
```html
<form id="cForm_736">
<table class="table">
  <thead>
    <tr>
      <td>Day</td>
      <td>Start Time</td>
      <td>End Time</td>
      <td>&nbsp;</td>
    </tr>
  </thead>
  <tbody id="tbody_736">
  </tbody>
</table>
</form>
<button id="cButton_736_add">Add Row</button>

<script>

function cFunc_736_updateData() {
    var data = $('#cForm_736').serializeArray();
    $('#{{ iID }}').val(JSON.stringify(data));
}

function cFunc_736_createRow(index) {
      $('#tbody_736').append('<tr id="cRow_736'+ index +'">'
                             + '<td><select name="cData_736_day'+ index +'"><option>Monday</option><option>Tuesday</option><option>Wednesday</option><option>Thursday</option><option>Friday</option></select></td>'
                             + '<td><input type="text" name="cData_736_startTime'+ index +'"></input></td>'
                             + '<td><input type="text" name="cData_736_endTime'+ index +'"></input></td>'
                             + '<td><img onclick="$(\'#cRow_736'+ index +'\').remove(); cFunc_736_updateData();" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></td>'
                             + '</tr>');
}

$(function() {

  var index = 0;
  var numColumns = 3;
  $('#cButton_736_add').on('click', function() {
      cFunc_736_createRow(index);
       index++;
  });

  $('#cForm_736').on('change', function() {
	cFunc_736_updateData();
  });
  
  var data = JSON.parse($('#{{ iID }}').val());

  for(var i = 0; i < data.length; i += numColumns) {
    cFunc_736_createRow(index);
    $('select[name=cData_736_day' + index + ']').val(data[i].value);
    $('input[name=cData_736_startTime' + index + ']').val(data[i + 1].value);
    $('input[name=cData_736_endTime' + index + ']').val(data[i + 2].value);
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
