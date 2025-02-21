# Download Files from Multiple Records

This tool simplifies the process of downloading file attachments (one per record) from a set of records. It creates a ZIP archive file containing the file attachments.

## How to configure
1. Update `IndicatorID` with the ID of the file upload field.
2. Use the Report Builder to identify the records that should be downloaded.
   - Include the data column for the file attachment in Step 2.
   - After generating the report, click JSON, and select the "Javascript Template" option in the dropdown.
3. Review the section containing `query.importQuery`, and replace it with the one provided by the Report Builder.

```html
<script src="../libs/js/LEAF/intervalQueue.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js" integrity="sha512-XMVd28F1oH/O71fzwBnV7HucLxVwtxf26XV8P4wPk26EDxuGZ91N8bsOttmnomcCD3CS5ZMRL50H0GgOHvegtg==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script>
var IndicatorID = 1; // ID of a file upload field

function saveFile(data, filename) {
    try {
        const blob = new Blob([data], { type: "application/octet-stream" });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = filename;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
    } catch (error) {
        console.error('Error saving ArrayBuffer as file:', error);
    }
}

async function buildAndDownload(results, filename) {
    $('#status').html(`Loading...`);
    const zip = new JSZip();
    
    let numResults = Object.keys(results).length;
    let queue = new intervalQueue();
    queue.setQueue(Object.keys(results));
    queue.setWorker(function(recordID) {
    	return $.ajax({
    		type: 'GET',
        	url: `file.php?form=${recordID}&id=${IndicatorID}&series=1&file=0`
    	}).then(function(res) {
            zip.file(`${results[recordID].s1.['id'+IndicatorID]}`, res);
        	$('#status').html(`Loading ${queue.getLoaded()} of ${numResults}...`);
        });
    });
    
	await queue.start();
    
    zip.generateAsync({
        type:"blob",
        compression: "DEFLATE",
        compressionOptions: {
            level: 9
        }
    }).then(async function(content) {
        saveFile(content, filename);
        $('#status').html(``);
    });
    
}

async function main() {
    document.querySelector('title').innerText = 'Download Attachments';
    
    let timestamp = Math.round(new Date().getTime() / 1000);
    let filename = `Attachments_${timestamp}.zip`;
    document.querySelector('#filename').innerHTML = filename;
    
    let query = new LeafFormQuery();
    query.importQuery({"terms":[{"id":"categoryID","operator":"=","match":"form_81f29","gate":"AND"},{"id":"stepID","operator":"=","match":"resolved","gate":"AND"},{"id":"dateSubmitted","operator":">=","match":"last year","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":[],"sort":{},"getData":["1"]});
    query.setExtraParams("&x-filterData=recordID");
    let results = await query.execute();
    
    let formGrid = new LeafFormGrid('records');
    formGrid.setDataBlob(results);
    formGrid.setHeaders([
        {name: 'Report', indicatorID: IndicatorID}
    ]);
    formGrid.renderBody();
    
    document.querySelector('#btn_generate').addEventListener('click', () => {
    	buildAndDownload(results, filename);
    });
}

document.addEventListener('DOMContentLoaded', main);

</script>
<h1>Download Attachments</h1>
<div style="display: flex; justify-content: center; align-items: center">
    <div id="records">Loading...</div>
    <img src="dynicons/image.php?img=go-next.svg&w=48">
    <div style="">
        <button id="btn_generate" class="buttonNorm">Compile and download <span id="filename">Attachments.zip</span></button>
        <div id="status"></div>
    </div>
</div>
```
