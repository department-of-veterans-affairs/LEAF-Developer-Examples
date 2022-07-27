# Copy an Orgchart Employee selection to a field on a different section

When an employee has been selected on the current data field, this will copy the selected employee's ID to the field with ID 123.

```js
<script>
$(function() {

    $('#{{ iID }}').on('change', function() {
        $.ajax({
            type: 'POST',
            url: 'api/form/{{ recordID }}',
            data: {
                CSRFToken: CSRFToken,
                123: $('#{{ iID }}').val()
            }
        });
    });

});
</script>
```
