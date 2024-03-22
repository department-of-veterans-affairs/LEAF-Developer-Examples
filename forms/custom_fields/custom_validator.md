# Custom Field Validation

Example: Show an error message if the user input doesn't start with a link.

```html
<div class="notUrl" style="display: none; color: red; font-weight: bold"><br />Please make sure you are providing a link (URL) to a LEAF site.</div>
<script>
formValidator["id{{ iID }}"] = {
	setValidator: function() {
      	let input = document.getElementById({{ iID }}).value;
      	return (input.length >= 4 && input.indexOf('http') == 0);
    },
    setValidatorError: function() {
      	document.querySelector('.notUrl').style.display = 'inline';
    },
  	setValidatorOk: function() {
      	document.querySelector('.notUrl').style.display = 'none';
    }
};
</script>
```
