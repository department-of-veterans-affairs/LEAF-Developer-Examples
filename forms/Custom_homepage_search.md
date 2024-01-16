# Custom Searchbar on the homepage

The searchbar on the homepage can be customized. Let's assume we have a datafield that contains ticket numbers formatted as RITM#####. We can enable searches based on that format by adding a logic gate.

First in the view_search template, find the section relating to the searchbar:
```js
        if(txt == '') {
            query.addTerm('title', 'LIKE', '*');
        }
        else if(!isNaN(parseFloat(txt)) && isFinite(txt)) { // check if numeric
            query.addTerm('recordID', '=', txt);
        }
```

Add a logic gate to check for input that starts with "RITM":

```js
        if(txt == '') {
            query.addTerm('title', 'LIKE', '*');
        }
        else if(txt.indexOf('RITM') == 0) {
            query.addDataTerm('data', ID_OF_THE_FIELD, 'MATCH', txt, 'AND'); // Replace ID_OF_THE_FIELD
            // query.addDataTerm('data', 0, 'MATCH', txt, 'AND'); // example to search all data fields
        }
        else if(!isNaN(parseFloat(txt)) && isFinite(txt)) { // check if numeric
            query.addTerm('recordID', '=', txt);
        }
```

Finally, the placeholder should be updated to help people understand they can search the RITM number.

Search for "placeholder", and modify:
```js
document.querySelector(`#${leafSearch.getPrefixID()}searchtxt`).placeholder = 'Record ID, RITM#, or Email...';
```
