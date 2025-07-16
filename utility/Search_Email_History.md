# Search Email History

This provides a brute-force search capability for email history. Since it's currently not possible to efficiently search within email history, this iterates through the "View History" output for each request.
<img width="1239" height="352" alt="image" src="https://github.com/user-attachments/assets/49bb2e17-1e5d-4e49-95eb-5bffae1744e4" />

## Prerequisite
1. This file must be loaded in the Report Programmer area

```html
<script src="../libs/js/LEAF/intervalQueue.js"></script>

<style>
#content {
    margin: 1rem;
}
</style>
<h1>Search Email History</h1>
<h2>This searches the email history for a set of records for records submitted within the past year</h2>
<h3 id="status"></h3>

<div id="setup">
    <label>Select form type: <select id="form"></select></label><br />
    <label>Recipient's Email: <input id="email" type="text" /></label><br />
    <button onclick="search()" class="buttonNorm">Search</button>
</div>

<div id="grid"></div>

<script>
var CSRFToken = "<!--{$CSRFToken}-->";

function scrubHTML(input) {
    if(input == undefined) {
        return '';
    }
    let t = new DOMParser().parseFromString(input, 'text/html').body;
    while(input != t.textContent) {
        return scrubHTML(t.textContent);
    }
    return t.textContent;
}

async function showSetup() {
    document.querySelector('#setup').style.display = 'block';

    let activeForms = await fetch('api/formStack/categoryList').then(res => res.json());
    let forms = '<option></option>';
    activeForms.forEach(form => {
        forms += `<option value="${form.categoryID}">${form.categoryName}</option>`;
    });
    
    document.querySelector('#form').innerHTML = forms;
}

async function getEmailHistory(recordID) {
	return fetch(`ajaxIndex.php?a=getstatus&recordID=${recordID}`)
        .then(res => res.text())
    	.then(content => {
            let output = [];
            let elem = document.createElement('div');
            elem.innerHTML = content;
            elem.querySelectorAll('.agenda tbody tr').forEach(row => {
                let date = row.querySelector('td:nth-child(1)').innerText;
                let isEmail = row.querySelector('td:nth-child(2)').innerHTML;
                if(isEmail.indexOf('Email Sent:') >= 0) {
                    output.push({
                        date: date,
                        emailHistory: isEmail
                    });
                }
            });
            return output;
    });
}

function setStatus(status) {
    document.querySelector('#status').innerHTML = status;
}

async function search() {
    let categoryID = document.querySelector('#form').value;
    let email = document.querySelector('#email').value;
    
    setStatus('Searching for records...');
    let query = new LeafFormQuery();
    query.addTerm('categoryID', '=', categoryID);
    query.addTerm('submitted', '>=', 'last year');
    query.join('categoryName');
    query.setExtraParams('&x-filterData=recordID,userMetadata,categoryNames');
    let data = await query.execute();

    let queue = new intervalQueue();
    queue.setQueue(Object.keys(data));
    queue.setWorker(item => {
        setStatus(`Looking up email history  ${queue.getLoaded()} of ${Object.keys(data).length}...`);
    	return getEmailHistory(item).then((history) => {
        	data[item].history = history;
        });
    });
    await queue.start();
    
    if(email != '') {
        for(let i in data) {
            let foundEmail = false;
            data[i].history.forEach(item => {
            	if(item.emailHistory.indexOf(email) >= 0) {
                    foundEmail = true;
                }
            });

            if(foundEmail == false) {
                delete data[i];
            }
        }
    }
    
    let grid = new LeafFormGrid('grid');
    grid.enableToolbar();
    grid.setDataBlob(data);
    grid.setHeaders([
        {name: 'Type', indicatorID: 'type', editable: false, callback: (data, blob) => {
            if(blob[data.recordID].categoryNames != undefined) {
                document.querySelector(`#${data.cellContainerID}`).innerHTML = blob[data.recordID].categoryNames.join(' | ');
            }
        }},
        {name: 'Request Initiator', indicatorID: 'initiator', editable: false, callback: (data, blob) => {
            document.querySelector(`#${data.cellContainerID}`).innerHTML = blob[data.recordID].userMetadata.email;
        }},
        {name: 'Email History', indicatorID: 'email', editable: false, callback: (data, blob) => {
            let output = '';
            blob[data.recordID].history.forEach(item => {
            	output += `${item.date}<br />${item.emailHistory}<br /><br />`;
            });
            document.querySelector(`#${data.cellContainerID}`).innerHTML = output;
        }},
    ]);
    grid.renderBody();
    
    setStatus('');
}

async function main() {
	showSetup();
}

document.addEventListener('DOMContentLoaded', main);
</script>

```
