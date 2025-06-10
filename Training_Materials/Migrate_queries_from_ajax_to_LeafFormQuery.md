# Migrate queries from $.ajax() to LeafFormQuery
[LeafFormQuery](https://github.com/department-of-veterans-affairs/LEAF/blob/master/LEAF_Request_Portal/js/formQuery.js) simplifies the process of retrieving data from the form/query API.

We'll walk through a few examples and demonstrate key features.

Let's start by looking at an example without using LeafFormQuery:
```js
$.ajax({
    type: 'GET',
    url: 'api/form/query/?q={"terms":...';
    cache: false,
    async: false,
    success: function(result){
        // do something with the result
    }            
});
```

Note that within leaf.va.gov, it's not necessary to set cache: false. Our infrastructure is configured to preserve network resources when there's no changes in the data, by using strong [HTTP ETag](https://en.wikipedia.org/wiki/HTTP_ETag) validation. This helps ensure LEAF makes efficient use of network resources, which also provides a better user experience by minimizing loading time.

Here's how the same query would be run with LeafFormQuery:
```js
let query = new LeafFormQuery();
query.importQuery({"terms":...);
query.execute().then(result => {
    // do something with the result
});
```

We also recommend that larger programs take advantage of modern JavaScript syntax such as [async/await](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function) to improve code readability:
```js
async function myFunction() {
    let query = new LeafFormQuery();
    query.importQuery({"terms":...);

    let result = await query.execute();
    // do something with the result
}
```
Note that **await** must be nested within an **async function**.

Now imagine you need to retrieve 100,000 records. This might take a few seconds, and we want to avoid making the browser appear to freeze. With LeafFormQuery, large queries are automatically split into sections, and we can let users know how things are progressing:
```html
<div id="progress"></div>
<script>
async function main() {
    let query = new LeafFormQuery();
    query.onProgress(progress => {
        document.querySelector('#progress').innerHTML = `Scanning ${progress} records...`;
    });

    let result = await query.execute();
    // do something with the result

    document.querySelector('#progress').innerHTML = 'Done.';
}
document.addEventListener('DOMContentLoaded', main);
</script>
```
