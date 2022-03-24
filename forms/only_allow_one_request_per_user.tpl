<script>
    
let query = new LeafFormQuery();
query.addTerm('userID', '=', "<!--{$userID|escape:'quotes'}-->");
query.addTerm('stepID', '=', 'submitted');
query.addTerm('stepID', '!=', 'resolved');
query.addTerm('deleted', '=', 0);

query.execute().then(result => {
	if(Object.keys(result).length > 0) {
        alert('You currently have a request in process. It must be resolved before you can submit another request.');
        window.location = './';
    }
});
    
</script>
