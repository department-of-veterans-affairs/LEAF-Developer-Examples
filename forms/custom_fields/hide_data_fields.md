# Hiding Data Fields

Questions are presented to users in two contexts:
1. Edit Data
2. Read Data
These are controlled in the Form Editor -> the field -> Programmer.

## Edit Data context "html"
```html
<script>
async function main{{ iID }}() {
    document.querySelector('.blockIndicator_{{ iID }}').style.visibility = 'hidden';
}

// Wait for the page to fully load before running our function
if(document.readyState !== 'loading') {
    main{{ iID }}();
} else {
    document.addEventListener('DOMContentLoaded', main{{ iID }});
}
</script>
```

## Read Data context "htmlPrint"
```html
<script>
async function main{{ iID }}() {
    document.querySelector('#subIndicator_{{ iID }}_1').style.visibility = 'hidden';
}

// Wait for the page to fully load before running our function
if(document.readyState !== 'loading') {
    main{{ iID }}();
} else {
    document.addEventListener('DOMContentLoaded', main{{ iID }});
}
</script>
```
