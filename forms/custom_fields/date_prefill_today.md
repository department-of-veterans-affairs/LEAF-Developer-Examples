# Prefill Date with Today's date

This will prefill a date field with Today's date, if no date has been entered.

## Prerequisites
1. Field formatted with the `date` input format

## Setup
1. Open the date field's Programmer mode, and place this in the `html` section:

```html
<script>
$(function() {
  let tDate = new Date();
  today = tDate.toLocaleDateString();

  let elem = document.getElementById({{ iID }});
  if(elem.value == '') {
    elem.value = today;
  }
});
</script>
```
