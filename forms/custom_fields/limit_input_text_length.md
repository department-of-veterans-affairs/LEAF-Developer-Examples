# Limit maximum length for input fields

This example limits the maximum length to 5 characters in a `Single line text` field.

## Setup
1. Navigate to your form in the Form Editor
2. Create a new field in Section 1 with the `Single line text` input format
3. Open the field's "Programmer" mode, and place the following code in the `html` section:

```html
<script>
async function main{{ iID }}() {
    document.getElementById({{ iID }}).maxLength = 5;
}

// Wait for the page to fully load before running our function
if(document.readyState !== 'loading') {
    main{{ iID }}();
} else {
    document.addEventListener('DOMContentLoaded', main{{ iID }});
}
</script>
```
