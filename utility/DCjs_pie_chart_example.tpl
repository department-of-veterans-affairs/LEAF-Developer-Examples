<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/dc/4.2.7/style/dc.min.css" integrity="sha512-t38Qn1jREPvzPvDLgIP2fjtOayaA1KKBuNpNj9BGgiMi+tGLOdvDB+aWLMe2BvokHg1OxRLQLE7qrlLo+A+MLA==" crossorigin="anonymous" referrerpolicy="no-referrer" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/7.8.2/d3.min.js" integrity="sha512-oKI0pS1ut+mxQZdqnD3w9fqArLyILRsT3Dx0B+8RVEXzEk3aNK3J3pWlaGJ8MtTs1oiwyXDAH6hG6jy1sY0YqA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/crossfilter2/1.5.4/crossfilter.min.js" integrity="sha512-YTblpiY3CE9zQBW//UMBfvDF2rz6bS7vhhT5zwzqQ8P7Z0ikBGG8hfcRwmmg3IuLl2Rwk95NJUEs1HCQD4EDKQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/dc/4.2.7/dc.min.js" integrity="sha512-vIRU1/ofrqZ6nA3aOsDQf8kiJnAHnLrzaDh4ob8yBcJNry7Czhb8mdKIP+p8y7ixiNbT/As1Oii9IVk+ohSFiA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>

<script>
async function main() {
    let query = new LeafFormQuery();
    query.addTerm('stepID', '=', 'submitted');
	  query.addTerm('deleted', '=', 0);
    query.setLimit(1000); // get up to 1000 records
    
    let data = await query.execute();
    
    // simplify the data, limiting it to the fields we care about
    let parsedData = [];
    for(let i in data) {
        let temp = {};

        temp.lastStatus = data[i].lastStatus;

        parsedData.push(temp);
    }

    // This visualization library (DC.js) uses Crossfilter as its backend
    // https://github.com/crossfilter/crossfilter/wiki/API-Reference#crossfilter
    let facts = crossfilter(parsedData);
    
    // Define the dimension for this chart
    // https://github.com/crossfilter/crossfilter/wiki/API-Reference#dimension
    let dimension = facts.dimension(function(d) { return d.lastStatus; });
    
    // Define how the data should be grouped
    // https://github.com/crossfilter/crossfilter/wiki/API-Reference#group-map-reduce
    let group = dimension.group().reduceCount();
    
    // Initialize chart
    // https://dc-js.github.io/dc.js/docs/html/PieChart.html
    let chart = dc.pieChart(`#my_chart`);
    
    // Configure chart
    chart
        .useViewBoxResizing(true)
        .dimension(dimension)
        .group(group)
        .title(d => Math.round(d.value / dimension.groupAll().reduceCount().value() * 100) + "% " + d.key + ': ' + d.value)
        .ordering(function(d) { return d.value; })
        .ordinalColors(d3.schemeTableau10)
        .label(d => d.key);
    
    // Render chart(s)
    dc.renderAll();
}
    
document.addEventListener('DOMContentLoaded', main);
</script>

<div id="my_chart"></div>
