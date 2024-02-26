# Bulk Import Service Chiefs

- Prereq: this will only work with admin referrer checking disabled for ServiceController.php POST endpoints.

```html
<script src="../libs/js/LEAF/intervalQueue.js"></script>
<script>
async function getServices() {
    return fetch('api/service')
        .then(res => res.json())
        .then(data => {
            let out = {};
            for(let i in data) {
                out[data[i].serviceID] = data[i].service;
            }
            return out;
        });
}

async function findUser(input) {
    return fetch('<!--{$orgchartPath}-->/api/national/employee/search?q=' + input)
        .then(res => res.json())
    	.then(data => {
        	if(Object.keys(data).length != 1) {
                return false;
            } else {
                let idx = Object.keys(data)[0];
                return data[idx].userName;
            }
    	});
}

async function addUser(serviceID, userName) {
    return $.ajax({
        type: 'POST',
        url: 'api/service/' + serviceID + '/members',
        data: {userID: userName,
              CSRFToken: '<!--{$CSRFToken}-->'}
    });
}
    
async function importUsers(users) {
	let queue = new intervalQueue();
    queue.setWorker(user => {
    	return $.ajax({
        	type: 'POST',
            url: '<!--{$orgchartPath}-->/api/employee/import/_' + user.userName,
            data: {CSRFToken: '<!--{$CSRFToken}-->'}
        }).then((res) => {
            if(!isNaN(res)) {
                document.querySelector('#progress').innerHTML = 'Importing users... ' + queue.getLoaded();
                return addUser(user.serviceID, user.userName);
            }
        });
    });
    queue.setQueue(users);
    queue.start().then(() => {
    	document.querySelector('#progress').innerHTML = 'Import ended.';
    });
}

async function main() {
    document.querySelector('title').innerText = 'Mass import Service Chiefs';

    let services = await getServices();
    
    document.querySelector('#checkData').addEventListener('click', function() {
    	let data = document.querySelector('#input').value;
        let lines = data.split("\n");
        let userCheck = [];
        for(let i in lines) {
            let part = lines[i].split("\t");
            let name = part[0]
            let email = part[1];
            let serviceID = part[3];
            if(i == 0 && (name.toLowerCase() != 'name' || email.toLowerCase() != 'email' || serviceID.toLowerCase() != 'serviceid')) {
                alert('Check header format');
                return;
            }
            
            if(i == 0 || i == lines.length - 1) {
                continue;
            }
            
            if(services[serviceID] == undefined) {
                alert('Service ID does not exist: ' + serviceID);
                return;
            }
            
            let userQuery = {};
            userQuery.line = i;
            userQuery.serviceID = serviceID;
            if(email.toLowerCase().indexOf('@va.gov') == -1) {
                userQuery.q = name;
            } else {
                userQuery.q = email;
            }
            userCheck.push(userQuery);
        }
        
        let errors = 0;
        let confirmedUsers = [];
        let queue = new intervalQueue();
        queue.setWorker(userToCheck => {
        	return findUser(userToCheck.q)
                .then(result => {
                	document.querySelector('#progress').innerHTML = 'Checking users... ' + queue.getLoaded();
            		if(result == false) {
                        errors++;
                        alert('Issue with name or email, check line: ' + (parseInt(userToCheck.line) + 1) + ' - ' + userToCheck.q);
                        queue.setQueue([]);
                    }
                	else {
                        let user = {};
                        user.userName = result;
                        user.serviceID = userToCheck.serviceID;
                        confirmedUsers.push(user);
                    }
            	});
        });
        queue.setQueue(userCheck);
        queue.start().then(function() {
        	if(errors == 0) {
                importUsers(confirmedUsers);
            }
        });
    });
}

document.addEventListener('DOMContentLoaded', main);
</script>

<div id="step1">
    <h1>This is a mass-uploader for Admin Panel -> Service Chiefs</h1>
    <p>Copy paste data from Excel with this format:</p>
    <table class="table"><thead><th>name</th><th>email</th><th>Service Name (unused, but column needs to exist)</th><th>serviceID</th></thead>
        <tbody><tr><td>Doe, Jane</td><td>example@va.gov</td><td></td><td>123</td></tr></tbody>
    </table>
    <br /><br />
    <textarea id="input" cols="60" rows="20"></textarea>
    <br />
    <button id="checkData">Import</button>
</div>
<div>Progress:</div>
<div id="progress">Idle</div>

```
