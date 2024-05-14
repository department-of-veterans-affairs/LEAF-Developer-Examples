# VA Facility Quicksearch

```html
<script src="./files/visnFacilityHelper.js"></script>
<style>
#content {
    margin: 1rem;
}
</style>
<h1>VA Facility Quicksearch</h1>
<p id="lastUpdated"></p>
<div>
	<input id="search" type="text" placeholder="Search for Facility Name / Station ID / State Abbr. / VISN #" style="width: 50vw" />
    <div id="results" style="visibility: hidden"></div>
</div>

<script>
function convertToFormGrid(data) {
    let output = {};
    for(let i in data) {
        output[i+1] = data[i];
        output[i+1].recordID = i+1;
    }
    return output;
}

function search(txt) {
    txt = txt.toLowerCase();
    let results = [];

    if(txt.match(/^\d\d\d/)) { // station number
        results = facilityHelper.searchData('code', txt);
    }
    else if(txt.match(/^\d{1,2}$/)
           || txt.match(/visn\s?\d{1,2}/i)) { // visn number
        results = facilityHelper.searchData('visn', txt.replace('visn', '').trim());
    }
    else if(txt.match(/^\D\D$/)) { // state
        results = facilityHelper.searchData('state', txt);
    }
    else {
    	results = facilityData.filter(facility => facility.name.toLowerCase().indexOf(txt) > 0);
    }
    
    results = convertToFormGrid(results);
    formGrid.setData(Object.keys(results).map(key => results[key]));
    formGrid.setDataBlob(results);

    formGrid.renderBody();
    document.querySelector('#results').style.visibility = 'visible';
}

let lastQuery = '';
let timeSinceKeystroke = 0;
function handleInputLoop() {
    let query = document.querySelector('#search').value;
    timeSinceKeystroke += 150;

    if(timeSinceKeystroke > 300 && query != lastQuery) {
        search(query);
        lastQuery = query;
    }
}

var facilityHelper = new VAFacilityHelper();
var facilityData = facilityHelper.getData();
var formGrid;

async function main() {
    document.querySelector('title').innerText = 'VA Facility Quicksearch';

    document.querySelector('#search').addEventListener('keyup', evt => {
    	timeSinceKeystroke = 0;
    });
    
    document.querySelector('#lastUpdated').innerText = 'Last updated ' + facilityHelper.getUpdateDate().toLocaleDateString(undefined, {month: 'long', day: 'numeric', year: 'numeric'});
    
    formGrid = new LeafFormGrid('results');
    formGrid.enableToolbar();
    formGrid.hideIndex();
    formGrid.setHeaders([
		{name: 'VISN', indicatorID: 'visn', editable: false, callback: (data, blob) => {
            $('#' + data.cellContainerID).html(blob[data.recordID].visn);
        }},
		{name: 'Station Number', indicatorID: 'code', editable: false, callback: (data, blob) => {
            $('#' + data.cellContainerID).html(blob[data.recordID].code);
        }},
        {name: 'Facility Name', indicatorID: 'name', editable: false, callback: (data, blob) => {
            $('#' + data.cellContainerID).html(blob[data.recordID].name);
        }},
        {name: 'Classification', indicatorID: 'class', editable: false, callback: (data, blob) => {
            $('#' + data.cellContainerID).html(blob[data.recordID].class);
        }},
		{name: 'City', indicatorID: 'city', editable: false, callback: (data, blob) => {
            $('#' + data.cellContainerID).html(blob[data.recordID].city);
        }},
        {name: 'State', indicatorID: 'state', editable: false, callback: (data, blob) => {
            $('#' + data.cellContainerID).html(blob[data.recordID].state);
        }}
    ]);
    
	setInterval(function () {
        handleInputLoop();
    }, 150);
}

document.addEventListener('DOMContentLoaded', main);
</script>
```
