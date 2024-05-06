This is a template for Single Page Applications developed in the LEAF Programmer.

Take note of the title assignment, this helps users of your application navigate between different browser tabs or windows.

Feel free to remove or modify any LEAF header/footer branding to maximize focus on your application's interface. For convenience you can quickly remove headers by appending "&iframe=1" to any LEAF URL.

```html
<style>
#content {
    margin: 1rem;
}
</style>
<h1>YOUR_APP_HEADING</h1>
<h2>YOUR_APP_SUBHEADING</h2>
<p>CONTENT</p>

<script>
async function main() {
    document.querySelector('title').innerText = 'YOUR_APP_TITLE';

    
}

document.addEventListener('DOMContentLoaded', main);
</script>
```
