# Cancelling a request

```js
let recordID = YOUR_RECORD_ID_TO_CANCEL;
let comment = 'OPTIONAL COMMENT';

$.ajax({
    type: 'POST',
    url: `api/form/${recordID}/cancel`,
    data: {CSRFToken: '<!--{$CSRFToken}-->',
        comment: comment},
    success: function(response) {
        if (response == 1) {
            window.location.href=`index.php?a=cancelled_request&cancelled=${recordID}`;
        } else {
            alert(response);
        }
    },
    error: function() { console.log('There was an error canceling the request!'); }
});
```
