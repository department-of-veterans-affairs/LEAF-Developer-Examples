# Custom Combined Inbox v3

Most people should use the standard Inbox. The following code is an early version of the standard Inbox.

```html
<script src="../libs/js/sha1.js"></script>
<script src="/launchpad/files/intervalQueue.js"></script>
<script>
    let CSRFToken = '<!--{$CSRFToken}-->';

    /**
     * This script creates a combined inbox of multiple LEAF sites.
     * 
     * You may configure the sites that will be loaded in the "sites" variable.
     * 
     * Additionally, each site may be configured with the following custom properties:
     * - url: Define the full url with backslash at end.
     * - name: Title of the LEAF in the combined inbox.
     * - backgroundColor: Background color of the site's section
     * - fontColor: Font color of the site's title
     * - icon: (Optional) This is an image used to represent the site's section, sourced from the
     *      Icon Repository: /libs/dynicons/gallery.php
     * - nonadmin: Set to true if you want Admins to see only their own info and not all requests
     */
var sites = [
    {
        url: './',
    	name: 'RMC',
        backgroundColor: '#F2F2F2',
        fontColor: 'black',
        icon: 'emblem-readnews.svg'
    },
];


    // Do Not Edit!! (Only Edit Sites Above)

    // Initiate script and set loading wheel
    function renderInbox() {
        for (let i in sites) {
            // sort by dependency description
            let depDesc = {};
            for (let j in dataInboxes[sites[i].url]) {
                depDesc[dataInboxes[sites[i].url][j].dependencyDesc] = j;
            }
            let sortedDepDesc = Object.keys(depDesc).sort();
            
            sortedDepDesc.forEach(depName => {
            	let depID = depDesc[depName];
                buildDepInbox(dataInboxes[sites[i].url], depID, sites[i]);
            });
        }
        $('#loading').slideUp();
        $('.inbox').fadeIn();
    }

    // Get site icons and name
    function getIcon(icon, name) {
        if (icon != '') {
            if (icon.indexOf('/') != -1) {
                icon = '<img src="' + icon + '" alt="icon for ' + name + '" style="vertical-align: middle" />';
            } else {
                icon = '<img src="dynicons/?img=' + icon + '&w=76" alt="icon for ' + name + '" style="vertical-align: middle" />';
            }
        }
        return icon;
    }

    // Build forms and grids for the inbox's requests and import to html tags
    function buildDepInbox(res, depID, site) {
        let hash = Sha1.hash(site.url);
        let dependencyName = res[depID].dependencyDesc;
        if (String(depID).substr(0, 2) == '-1') {
            dependencyName = res[depID].approverName != null ? res[depID].approverName : 'Person designated by requestor';
        }
        if (String(depID).substr(0, 2) == '-3') {
            dependencyName = res[depID].approverName != null ? res[depID].approverName : 'Group designated by requestor';
        }
        let icon = getIcon(site.icon, site.name);
        if (document.getElementById('siteContainer' + hash) == null) {
            $('#indexSites').append('<li style="font-size: 120%; line-height: 150%"><a href="#' + hash + '">' + site.name + '</a></li>');
            $('#inbox').append('<div id="siteContainer' + hash + '" style="border-left: 4px solid ' + site.backgroundColor + '; border-right: 4px solid ' + site.backgroundColor + '; border-bottom: 4px solid ' + site.backgroundColor + '; margin: 0px auto 8px">'
                + '<a name="' + hash + '" />'
                + '<div style="font-weight: bold; font-size: 200%; line-height: 240%; background-color: ' + site.backgroundColor + '; color: ' + site.fontColor + '; ">' + icon + ' ' + site.name + '</div>'
                + '</div>');
        }
        $('#siteContainer' + hash).append('<div id="depContainer' + hash + '_' + depID + '" style="border: 1px solid black; background-color: ' + res[depID].dependencyBgColor + '; cursor: pointer; margin: 4px">'
            + '<div id="depLabel' + hash + '_' + depID + '" class="depInbox" style="padding: 8px"><span style="float: right; text-decoration: underline; font-weight: bold">View ' + res[depID].count + ' requests</span>'
            + '<span style="font-size: 120%; font-weight: bold">' + dependencyName + '</span>'
            + '</div>'
            + '<div id="depList' + hash + '_' + depID + '" style="width: 90%; margin: auto; display: none"></div></div><br />');
        $('#depLabel' + hash + '_' + depID).on('click', function () {
            if ($('#depList' + hash + '_' + depID).css('display') == 'none') {
                $('#depList' + hash + '_' + depID).css('display', 'inline');
            } else {
                $('#depList' + hash + '_' + depID).css('display', 'none');
            }
        });
        let formGrid = new LeafFormGrid('depList' + hash + '_' + depID);
        formGrid.setRootURL(site.url);
        formGrid.disableVirtualHeader(); // TODO: figure out why headers aren't sized correctly
        formGrid.setDataBlob(res);
        formGrid.hideIndex();
        formGrid.setHeaders([
            {
                name: 'UID', indicatorID: 'uid', editable: false, callback: function (data, blob) {
                    $('#' + data.cellContainerID).html('<a href="' + site.url + '?a=printview&recordID=' + data.recordID + '">' + data.recordID + '</a>');
                }
            }
            ,
            {
                name: 'Type', indicatorID: 'type', editable: false, callback: function (data, blob) {
                    let categoryNames = '';
                    if (blob[depID]['records'][data.recordID].categoryNames != undefined) {
                        categoryNames = blob[depID]['records'][data.recordID].categoryNames.replace(' | ', ', ');
                    }
                    else {
                        categoryNames = '<span style="color: #ff0000">Warning: This request is based on an old or deleted form.</span>';
                    }
                    $('#' + data.cellContainerID).html(categoryNames);
                    $('#' + data.cellContainerID).attr('tabindex', '0');
                }
            },
            {
                name: 'Service', indicatorID: 'service', editable: false, callback: function (data, blob) {
                    $('#' + data.cellContainerID).html(blob[depID]['records'][data.recordID].service);
                    $('#' + data.cellContainerID).attr('tabindex', '0');
                }
            },
            {
                name: 'Title', indicatorID: 'title', editable: false, callback: function (data, blob) {
                    $('#' + data.cellContainerID).attr('tabindex', '0');
                    $('#' + data.cellContainerID).attr('aria-label', blob[depID]['records'][data.recordID].title);
                    $('#' + data.cellContainerID).html('<a href="'+ site.url +'index.php?a=printview&recordID=' + data.recordID + '" target="_blank">'
                        + blob[depID]['records'][data.recordID].title + '</a>'
                        + ' <button id="' + data.cellContainerID + '_preview" class="buttonNorm">Quick View</button>'
                        + '<div id="inboxForm' + hash + '_' + depID + '_' + data.recordID + '" style="background-color: white; display: none; height: 300px; overflow: scroll"></div>');
                    $('#' + data.cellContainerID + '_preview').on('click', function () {
                        $('#' + data.cellContainerID + '_preview').hide();
                        if ($('#inboxForm' + hash + '_' + depID + '_' + data.recordID).html() == '') {
                            $('#inboxForm' + hash + '_' + depID + '_' + data.recordID).html('Loading...');
                            $('#inboxForm' + hash + '_' + depID + '_' + data.recordID).slideDown();
                            $.ajax({
                                type: 'GET',
                                url: site.url + 'ajaxIndex.php?a=printview&recordID=' + data.recordID,
                                success: function (res) {
                                    $('#inboxForm' + hash + '_' + depID + '_' + data.recordID).html(res);
                                    $('#inboxForm' + hash + '_' + depID + '_' + data.recordID).slideDown();
                                    $('#requestTitle').attr('tabindex', '0');
                                    $('#requestInfo').attr('tabindex', '0');
                                }
                            })
                        }
                    })
                }
            },
            {
                name: 'Status', indicatorID: 'currentStatus', editable: false, callback: function (data, blob) {
                    let listRecord = blob[depID]['records'][data.recordID];
                    let cellContainer = $('#' + data.cellContainerID);
                    let waitText = listRecord.blockingStepID == 0 ? 'Pending ' : 'Waiting for ';
                    let status = '';
                    if (listRecord.stepID == null && listRecord.submitted == '0') {
                        status = '<span style="color: #e00000">Not Submitted</span>';
                    }
                    else if (listRecord.stepID == null) {
                        let lastStatus = listRecord.lastStatus;
                        if (lastStatus == '') {
                            lastStatus = '<a href="index.php?a=printview&recordID=' + data.recordID + '">Check Status</a>';
                        }
                        status = '<span style="font-weight: bold">' + lastStatus + '</span>';
                    }
                    else {
                        status = waitText + listRecord.stepTitle;
                    }

                    if (listRecord.deleted > 0) {
                        status += ', Cancelled';
                    }

                    cellContainer.html(status).attr('tabindex', '0').attr('aria-label', status);
                    if (listRecord.userID == '<!--{$userID}-->') {
                        cellContainer.css('background-color', '#feffd1');
                    }
                }
            },
            {
                name: 'Action', indicatorID: 'action', editable: false, sortable: false, callback: function (data, blob) {
                    let depDescription = 'Take Action';
                    $('#' + data.cellContainerID).html('<button id="btn_action' + hash + '_' + depID + '_' + data.recordID + '" class="buttonNorm" style="text-align: center; font-weight: bold; white-space: normal">' + depDescription + '</button>');
                    $('#btn_action' + hash + '_' + depID + '_' + data.recordID).on('click', function () {
                        loadWorkflow(data.recordID, depID, formGrid.getPrefixID(), site.url);
                    })
                }
            }
        ])
        let tGridData = [];
        let hasServices = false;
        for (let i in res[depID].records) {
            if (res[depID].records[i].service != null) {
                hasServices = true;
            }
            tGridData.push(res[depID].records[i]);
        }
        // remove service column if there's no services
        if (hasServices == false) {
            let tHeaders = formGrid.headers();
            tHeaders.splice(1, 1);
            formGrid.setHeaders(tHeaders);
        }
        formGrid.setData(tGridData);
        formGrid.sort('recordID', 'desc');
        formGrid.renderBody();
        //formGrid.loadData(tGridData.map(v => v.recordID).join(','));
        $('#' + formGrid.getPrefixID() + 'table').css('width', '99%');
        $('#' + formGrid.getPrefixID() + 'header_title').css('width', '60%');
        $('#depContainerIndicator_' + depID).css('display', 'none');
    }
    let dataInboxes = {};
    let sitesLoaded = [];

    // API Requests for inbox data from each site
    function loadInboxData(site, nonadmin) {
        site = site == undefined ? '' : site;
        let siteURL = site + './api/?a=inbox/dependency/_';

        if (nonadmin) {
            siteURL += '&masquerade=nonAdmin';
        }
        return $.ajax({
            type: 'GET',
            url: siteURL,
            success: function (res) {
                dataInboxes[site] = res;
            },
            error: function (err) {
                alert('Error: ' + err.statusText);
            },
            cache: false
        });
    }

    function loadWorkflow(recordID, dependencyID, prefixID, rootURL) {
        dialog_message.setTitle('Apply Action to #' + recordID);
        currRecordID = recordID;
        dialog_message.setContent('<div id="workflowcontent"></div><div id="currItem"></div>');
        workflow = new LeafWorkflow('workflowcontent', '<!--{$CSRFToken}-->');
        workflow.setRootURL(rootURL);
        workflow.setActionSuccessCallback(function () {
            dialog_message.hide();
            $('#' + prefixID + 'tbody_tr' + recordID).fadeOut(1500);
        });
        workflow.getWorkflow(recordID);
        dialog_message.show();
    }

    let dialog_message;
    // Script Start
    $(function () {
        dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator', 'genericDialogbutton_save', 'genericDialogbutton_cancelchange');

        let progressbar = $('#progressbar').progressbar();
        $('#progressbar').progressbar('option', 'max', Object.keys(sites).length);
        let queue = new intervalQueue();
        queue.setWorker(site => {
            $('#progressbar').progressbar('option', 'value', queue.getLoaded());
            $('#progressDetail').html(`Retrieving records from ${site.name}...`);
            return loadInboxData(site.url, site.nonadmin);
        });
        queue.onComplete(() => {
            $('#progressContainer').slideUp();
            renderInbox();
        });

        sites.forEach(site => queue.push(site));

        queue.start();

        $('#btn_expandAll').on('click', function () {
            $('.depInbox').click();
        });

        $('#headerTab').html('My Inbox');
    });
</script>
<style>
    #inboxContainer {
		display: grid;
        grid-template-columns: min-content 1fr;
        grid-column-gap: 1rem;
    }
    #index {
        position: sticky;
        top: 0;
        margin-top: 25px;
        overflow-y: auto;
        max-height: 75vh;
        width: 20vw;
        background-color: white;
        border: 1px solid black;
        padding: 1rem;
    }
    .inbox {
        display: none;
    }
</style>
<div id="genericDialog" style="visibility: hidden; display: none">
    <div>
        <div id="genericDialogbutton_cancelchange" style="display: none"></div>
        <div id="genericDialogbutton_save" style="display: none"></div>
        <div id="genericDialogloadIndicator"
            style="visibility: hidden; z-index: 9000; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background-color: #f2f5f7; padding: 16px; height: 400px; width: 526px">
            <img src="images/largespinner.gif" alt="loading..." />
        </div>
        <div id="genericDialogxhr" style="width: 540px; height: 420px; padding: 8px; overflow: auto; font-size: 12px">
        </div>
    </div>
</div>
<div id="progressContainer" style="width: 50%; border: 1px solid black; background-color: white; margin: auto; padding: 16px">
    <h1 style="text-align: center">Loading...</h1>
    <div id="progressbar"></div>
    <h2 id="progressDetail" style="text-align: center"></h2>
</div>
<div id="inboxContainer">
    <div id="index" class="inbox">Jump to section:
        <ul id="indexSites"></ul>
    </div>
    <div id="inbox" class="inbox">
            <button id="btn_expandAll" class="buttonNorm" style="float: right">Toggle sections</button>
    </div>
</div>

```
