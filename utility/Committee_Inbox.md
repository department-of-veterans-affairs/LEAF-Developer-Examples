<style>
#content {
    margin: 1rem;
}
p, .card {
    font-size: 1rem;
}
.card {
    padding: 1rem;
    margin-bottom: 1rem;
}
</style>
<script>
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

    let forms = await fetch('api/workflow/steps').then(res => res.json());
    let buf = '';
    for(let i in forms) {
        buf += `<option value="${forms[i].stepID}">${scrubHTML(forms[i].stepTitle)}</option>`;
    }

    document.querySelector('#steps').innerHTML = buf;
    document.querySelector('#create').addEventListener('click', () => {
        let stepID = document.querySelector('#steps').value;
        let url = window.location.href;
        
        url += `&stepID=${stepID}`;

        window.location = url;
    });
}

async function setupProposals(stepID) {
    document.querySelector('#setupProposals').style.display = 'block';

    let stepInfo = await fetch('api/workflow/step/1').then(res => res.json());
    let routeInfo = await fetch(`api/workflow/${stepInfo.workflowID}/route`).then(res => res.json());
    let activeCategoryData = await fetch('api/formStack/categoryList').then(res => res.json());
    let activeCategories = {};
    let actions = [];
    
    routeInfo.forEach(route => {
    	if(route.stepID == stepID) {
            actions.push(route);
        }
    });
    
    // need this to provide a cleaner view (e.g. avoid showing names of stapled forms)
    activeCategoryData.forEach(cat => {
    });
    
    let htmlActions = '<option val=""></option>';
    actions.forEach(action => {
    	htmlActions += `<option val="${action.actionType}">${action.actionText}</option>`;
    });
    
    let query = new LeafFormQuery();
    query.addTerm('stepID', '=', stepID);
    query.join('categoryName');
    let data = await query.execute();
    
    let grid = new LeafFormGrid('proposalGrid');
    grid.setDataBlob(data);
    grid.setHeaders([
		{name: 'Type', indicatorID: 'type', editable: false, callback: function(data, blob) {
            document.querySelector(`#${data.cellContainerID}`).innerHTML = blob[data.recordID].categoryNames.join(' | ');
        }},
        {name: 'Decision', indicatorID: 'decision', editable: false, callback: function(data, blob) {
            let options = `<select>
    				${htmlActions}
    			</select>`;
            document.querySelector(`#${data.cellContainerID}`).innerHTML = options;
        }}
    ]);
    grid.renderBody();
}

async function main() {
    document.querySelector('title').innerText = 'Committee Inbox';

    const urlParams = new URLSearchParams(window.location.search);
    let stepID = urlParams.get('stepID');
    let proposals = urlParams.get('proposals');

    if(stepID != null) {
        if(proposals == null) {
            setupProposals(stepID);
        }
        else {
            console.log(stepID, proposals);
        }
    }
    else {
        showSetup();
    }
}

document.addEventListener('DOMContentLoaded', main);
</script>
<div id="setup" style="display: none">
    <h1>Setup Committee View</h1>
    <p>The Committee View provides a more focused interface to enable an approver to easily review and concur on proposed actions.</p>

    <br /><br />
    <div class="card">
        Select a step: <select id="steps"><option>Loading...</option></select>
        <br /><br />

        <button id="create" class="buttonNorm">Setup Proposed Actions</button>
        <br /><br />
    </div>
</div>
<div id="setupProposals" style="display: none">
    <h1>Setup Proposed Actions</h1>
    <p>Proposed actions will be presented for final review. Records without a proposed decision will not be listed during final review.</p>
    
    <div id="proposalGrid"></div>
</div>
