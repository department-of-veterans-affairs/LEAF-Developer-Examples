# Duration Selector

Converts the input of a numeric field into a duration selector with an hour drop-down list and a series of minute buttons:

![image](https://github.com/kduffy314/LEAF-Developer-Examples/assets/129002041/eae534df-eecc-4354-90d3-932cf88adf67)

The data is stored as the number of minutes.  The output display converts minutes to HH:MM format:

![image](https://github.com/kduffy314/LEAF-Developer-Examples/assets/129002041/8484916a-dc84-47fa-b63b-c60ec0169c63)

Notes:
- The "html" section is rendered in areas where the user is expected to input data
- The "htmlPrint" section is rendered in areas where the user is expected to view data

### "html" section:
```html
<style>
  .minButton {
	display: inline-block;
    border: 1px solid black;
    width: 25px;
    text-align: center; 
    padding: 5px;
    border-radius: 3px;
    cursor: pointer;
  	background-color: #efefef;
  }

  .minTD {
    border: 1px solid black;
    width: 25px;
    text-align: center; 
    padding: 5px;
    cursor: pointer;
  	background-color: #efefef;
  }
  
  .timeTD {
    border: 1px solid gray;
    color: gray;
    width: 35px;
    text-align: left; 
    padding: 5px;
  }  
</style>

<script>

  // Set HH:MM
  function durationDisplayHHMM_{{ iID }}(hour, minute) {
    let extra0 = '';
    if (minute < 10)
      extra0 = '0';
    $('#Time{{ iID }}').html(hour + ':' + extra0 + minute);    
  }
  
  // User clicked on one of the minute buttons, so color the buttons, display HH:MM, set the form field value
  function durationChooseMin_{{ iID }}(minute) {    
    // color the buttons so that selected button is dark and the others are light
  	for (let i = 0; i < 12; i++) {
      if (minute == i*5)
          $('#min{{ iID }}_' + i*5).css('background-color', 'darkgray');
      else
          $('#min{{ iID }}_' + i*5).css('background-color', '');        
  	}
    
    // Get selected hour
    let hour = $('#Hour{{ iID }}').find(":selected").val();

	// update display of HH:MM    
    durationDisplayHHMM_{{ iID }}(hour, minute);
    
    // Store total minutes in form field
    $('#{{ iID }}').val(hour * 60 + minute);
  } 

  // User selected a different hour from dropdown, so get the hour value selected, get the current minute value selected, display HH:MM, set the form field value
  function durationChooseHour_{{ iID }}() {
    // Get selected hour
    let hour = $('#Hour{{ iID }}').find(":selected").val();
  
    // Get selected min
    let minute = 0;
    let selectedColor = 'rgb(169, 169, 169)';
    let minColor = '';
    for (let i = 0; i < 12; i++) {
      minColor = $('#min{{ iID }}_'+i*5).css('background-color');
      if (minColor == selectedColor) {
        minute = i*5;
        break;
      }
    }

	// update display of HH:MM    
    durationDisplayHHMM_{{ iID }}(hour, minute);
    
    // Store total minutes in form field
    $('#{{ iID }}').val(hour * 60 + minute);
  } 
  
  $(function() {    
  
    // Hide official field numeric input which is used to store the number of calculated minutes
    $(".response.blockIndicator_{{ iID }}").attr("style", "display: none;");
    
    // Create new label which contains new input UI (hours dropdown, minute buttons) and output UI (HH:MM)
    
    // Get the field's actual label	
    let actualLabelObject = $('label[for="{{ iID }}"]');
    let actualLabel = actualLabelObject[0].innerHTML;
	//    console.log('#' + actualLabel + '#');
    
    // Start the new label with the actual label's HTML
    let label_html = '<p>' + actualLabelObject[0].innerHTML + '</p>';
    
    // Add HH:MM
    label_html += '<table style="display:inline-block;vertical-align: bottom;"><tr><td class="timeTD" id="Time{{ iID }}"></td></tr></table>';

    // Add Hours dropdown - 0 to 39
    label_html += '&nbsp;&nbsp;&nbsp;&nbsp;Hours: ';
    label_html = label_html + '<select name="Hour{{ iID }}" id="Hour{{ iID }}" onchange="durationChooseHour_{{ iID }}()" style="margin: 2px">';
  	for (let i = 0; i < 40; i++) {
    	label_html += '<option value="' + i + '">' + i + '</option>';
  	}
  	label_html += '</select>&nbspMin:&nbsp;';
    
    // Add 12 Minute buttons: 00, 05, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55
    label_html += '<table style="display:inline-block;vertical-align: bottom;"><tr>'
    let extra0 = '';
    for (let i = 0; i < 12; i++) {
      if (i*5 < 10)
        extra0 = '0';
      else extra0 = '';
      label_html += '<td id="min{{ iID }}_' + i*5 + '" class="minTD" onclick="durationChooseMin_{{ iID }}(' + i*5 + ')">' + extra0 + i*5 + '</td>'
    }
    label_html += '</tr></tr></table><br>'
    
    // Set the label
  	$('.sublabel.blockIndicator_{{ iID }}').html(label_html);

    // Get form field's stored minutes and convert into hours and seconds
    let storedValue = '{{ data }}';
    if (storedValue == '')
      storedValue = 0;
    let HourComponent = Math.floor(storedValue / 60);
    let MinuteComponent = storedValue % 60;

    // Set hours dropdown
    $('#Hour{{ iID }}').val(HourComponent);
        
    // Color the minute buttons to set the minutes
  	for (let x = 0; x < 12; x++) {
      if (x == Math.floor(MinuteComponent / 5))
          $('#min{{ iID }}_'+x*5).css('background-color', 'darkgray');
      else
          $('#min{{ iID }}_'+x*5).css('background-color', '');        
  	}

	// update display of HH:MM    
    durationDisplayHHMM_{{ iID }}(HourComponent, MinuteComponent);
  });  
</script>
```

### "htmlPrint" section:
```html
<script>
  
  $(function() {   
    let storedValue = $('#data_{{ iID }}_1').html();   
    let HourComponent = Math.floor(storedValue / 60);
    let MinuteComponent = storedValue % 60;

    // convert to HH:MM:
    let extra0 = '';
    if (MinuteComponent < 10)
      extra0 = '0';
    $('#data_{{ iID }}_1').html(HourComponent + ':' + extra0 + MinuteComponent);    
  
  });
</script>
```
