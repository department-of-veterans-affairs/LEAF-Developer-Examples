# Bulk Exporter for Nationally Standardized Sites (prototype)
This is a LEAF Programmer script designed to be run from a Standardized Primary site.

Data is retrieved from all subordinate sites and combined into a single file. It's then uploaded to the Primary site for access control and retrieval. This script will generate CSV and JSON files.

## Prerequsites
1. The primary site will need a Form created to store the data. This form should have a field with the "fileupload" input format.
2. An empty record should be created for the Form.
3. Update the code with the field ID from #1 and record ID from #2.
4. The person running this script should have access to data from all sites associated with the Primary.


```html
<!--{if $empMembership['groupID'][1]}-->
<script src="../libs/js/LEAF/intervalQueue.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js" integrity="sha512-XMVd28F1oH/O71fzwBnV7HucLxVwtxf26XV8P4wPk26EDxuGZ91N8bsOttmnomcCD3CS5ZMRL50H0GgOHvegtg==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<style>
li {
    padding: 8px;
}
</style>
<h1>National Data Export</h1>
<div id="loadingIndicator"><h1>Loading...</h1>
    <h2 id="loadingStatus"></h2>
</div>
<div id="errors"></div>
<div id="ui_container" style="display: none"></div>
<script>
// Upload files to:
let recordID = 103;
let indicatorID = 28;

async function getSites() {
    return $.ajax({
        type: 'GET',
        url: './api/system/settings',
        cache: false
    })
    .then(function(res) {
        if(res.siteType != 'national_primary') {
            $('#ui_container').html('<h1>This site is not configured as a primary national distribution site.</h1>');
            $('#loadingIndicator').slideUp();
            $('#ui_container').fadeIn();
            return [];
        }
        else {
            sites = res.national_linkedSubordinateList.split(/\n/).filter(function(site) {
                return site != "" ? true : false;
            });
            sites.shift(); // skip test site
            return sites;
        }
    });
}

async function getForms() {
    let activeForms = [];
    return $.ajax({
    	type: 'GET',
        url: './api/formStack/categoryList/all',
    }).then(res => {
    	res.forEach(form => {
        	if(form.workflowID > 0) {
                activeForms.push(form);
            }
        });
        return activeForms;
    });
}

async function getFormFields(formID) {
    let formFields = {};
    return $.ajax({
    	type: 'GET',
        url: `./api/form/_${formID}/flat`,
    }).then(res => {
    	for(let i in res) {
            if(res[i][1].format != '') {
                let tmp = document.createElement('div');
                tmp.innerHTML = res[i][1].name;

                formFields[i] = {};
                formFields[i].name = tmp.innerText; // strip html
                
                if(formFields[i].name.length > 20) {
                    formFields[i].name = formFields[i].name.substring(0, 20) + '...';
                }
                
                // prefer short label instead of full name
                if(res[i][1].description != '') {
                	formFields[i].name = res[i][1].description;
                }
                formFields[i].format = res[i][1].format;
            }
        }
        return formFields;
    });
}

async function buildExport(sites, formID, formName) {
    // Sanitize formName
    let cleanText = document.createElement('div');
    cleanText.innerHTML = formName;
    formName = cleanText.innerText;
    
    
    let formFields = await getFormFields(formID);
    let parsedData = [];

    let queue = new intervalQueue();
    queue.setConcurrency(3);
    queue.setWorker(function(site) {
        let query = new LeafFormQuery();
        query.setRootURL(site);
        query.addTerm('categoryID', '=', formID);
        query.addTerm('deleted', '=', 0);
        query.addTerm('submitted', '>', 0);
        query.join('status');
        query.join('stepFulfillment');
        query.setExtraParams('&x-filterData=submitted,stepTitle,userID,lastStatus,date,stepFulfillment');

        Object.keys(formFields).forEach(indicatorID => {
            query.getData(indicatorID);
        });

        return query.execute().then(function(res) {
            $('#loadingStatus').html(`Retrieving data from ${queue.getLoaded()} of ${sites.length} sites`);

            for(let i in res) {
                let tmp = {};
                tmp.site = site;
                tmp.recordID = i;
                tmp.status = res[i].stepTitle == null ? res[i].lastStatus : 'Pending ' + res[i].stepTitle;
                tmp.userID = res[i].userID;
                tmp.dateInitiated = res[i].date + '';
                tmp.dateApprovedByCOS = res[i]?.stepFulfillment?.[15]?.time == undefined ? '' : res[i]?.stepFulfillment?.[15]?.time + '';

                for(let j in formFields) {
                    tmp[formFields[j].name] = res[i].s1['id'+j]; // TODO: Detect duplicate labels

                    if(formFields[j].format == 'orgchart_employee') {
                        if(res[i].s1['id'+j+'_orgchart'] != undefined) {
                            tmp[formFields[j].name] = res[i].s1['id'+j+'_orgchart'].lastName + ', ' + res[i].s1['id'+j+'_orgchart'].firstName;
                            tmp[formFields[j].name + " (Email)"] = res[i].s1['id'+j+'_orgchart'].email;
                        }
                    }
                }

                parsedData.push(tmp);
            }
        });
    });

    sites.forEach(site => {
        queue.push(site);
    });


    await queue.start();

    $('#loadingStatus').html(`Building JSON report...`);

    let exportableData = JSON.stringify(parsedData);

    // Export JSON format
    let uploadData = new FormData();
    let blob = new Blob([ exportableData ], {type: 'application/json'});
    uploadData.append('CSRFToken', '<!--{$CSRFToken}-->');
    uploadData.append(indicatorID, blob, `${formName} (${formID}).json`);

    try {
        await $.ajax({
            type: 'POST',
            url: `./ajaxIndex.php?a=doupload&recordID=${recordID}`,
            data: uploadData,
            processData: false,
            contentType: false
        });
    } catch(e) {
        if(e.status != 200) {
            console.log(e);
        }
    }

    // compress JSON into ZIP file
    const zip = new JSZip();
    zip.file(`${formName} (${formID}).json`, exportableData);

    zip.generateAsync({
        type:"blob",
        compression: "DEFLATE",
        compressionOptions: {
            level: 9
        }
    }).then(async function(content) {
        let uploadData = new FormData();
        let blob = new Blob([ content ], {type: 'application/zip'});
        uploadData.append('CSRFToken', '<!--{$CSRFToken}-->');
        uploadData.append(indicatorID, blob, `${formName} (${formID}).zip`);

        try {
            await $.ajax({
                type: 'POST',
                url: `./ajaxIndex.php?a=doupload&recordID=${recordID}`,
                data: uploadData,
                processData: false,
                contentType: false
            });
        } catch(e) {
            if(e.status != 200) {
                console.log(e);
            }
        }
    });

    $('#loadingStatus').html(`Building CSV report...`);
    // format as CSV
    if(parsedData[0] != undefined) {
        exportableData = '';
        let headers = Object.keys(parsedData[0]);
        exportableData = headers.join(',') + "\r\n";

        for(let i in parsedData) {
            for(let j in headers) {
                let cleanText = document.createElement('div');
                cleanText.innerHTML = parsedData[i][headers[j]];
                cleanText = cleanText.innerText.replace('"', '&quot;');
                cleanText = cleanText.replace(/\n/g, ' ');
                cleanText = cleanText.replace(/\r/g, ' ');
                exportableData += `"${cleanText}",`;
            }
            exportableData += "\r\n";
        }
        //exportableData = exportableData.slice(0, -1);

        uploadData = new FormData();
        blob = new Blob([ exportableData ], {type: 'text/csv'});
        uploadData.append('CSRFToken', '<!--{$CSRFToken}-->');
        uploadData.append(indicatorID, blob, `${formName} (${formID}).csv`);

        try {
            await $.ajax({
                type: 'POST',
                url: `./ajaxIndex.php?a=doupload&recordID=${recordID}`,
                data: uploadData,
                processData: false,
                contentType: false
            });
        } catch(e) {
            if(e.status != 200) {
                console.log(e);
            }
        }
    }

    $('#loadingIndicator').slideUp();
    $('#ui_container').fadeIn();

    $('#ui_container').html(`<p>Files have been updated: <a href="./index.php?a=printview&recordID=${recordID}">./index.php?a=printview&recordID=${recordID}</a></p>`);
}

function renderFormSelector(forms) {
	$('#loadingIndicator').slideUp();
    $('#ui_container').fadeIn();
    
    let buf = '<ul>';
    forms.forEach(form => {
    	buf += `<li><a href="#${form.categoryID}" onclick="window.location.href += '#${form.categoryID}'; location.reload();">${form.categoryName}</a></li>`;
    });
    buf += '</ul>';
    $('#ui_container').html('<h2>Select a category:</h2>' + buf);
}

async function main() {
    let sites = await getSites();

    if(sites.length == 0) {
        return;
    }

    let tmpSites = [...sites];

    let openForm = window.location.hash.substring(1);
    let forms = await getForms();

    let foundForm = false;
    for(let i in forms) {
        if(forms[i].categoryID == openForm) {
            foundForm = true;
            buildExport(tmpSites, forms[i].categoryID, forms[i].categoryName);
        }
    }
    
	if(!foundForm) {
        renderFormSelector(forms);
    }
}

var sites;
$(function() {
	main();
});

</script>

<!--{else}-->
<h1>Admin access required</h1>
<!--{/if}-->
```
