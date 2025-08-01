# LeafFormQuery Documentation

## Table of Contents

*   [Overview](#overview)
*   [Methods](#methods)
    *   [addTerm(id, operator, match, gate)](#addtermid-operator-match-gate)
    *   [addDataTerm(id, indicatorID, operator, match, gate)](#adddatatermid-indicatorid-operator-match-gate)
    *   [importQuery(queryObject)](#importqueryqueryobject)
    *   [setLimit(offset, limit)](#setlimitoffset-limit)
    *   [setLimitOffset(offset)](#setlimitoffsetoffset)
    *   [join(table)](#jointable)
    *   [getData(indicatorID)](#getdataindicatorid)
    *   [sort(column, direction)](#sortcolumn-direction)
    *   [updateTerm(id, operator, match, gate)](#updatetermid-operator-match-gate)
    *   [updateDataTerm(id, indicatorID, operator, match, gate)](#updatedatatermid-indicatorid-operator-match-gate)
    *   [setExtraParams(params)](#setextraparamsparams)
    *   [setRootURL(url)](#setrooturlurl)
    *   [onSuccess(funct)](#onsuccessfunct)
    *   [onProgress(funct)](#onprogressfunct)
    *   [setAbortSignal(signal)](#setabortsignalsignal)
    *   [execute()](#execute)


## Overview

`LeafFormQuery` ([formQuery.js](https://github.com/department-of-veterans-affairs/LEAF/blob/master/LEAF_Request_Portal/js/formQuery.js)) is a globally available object on LEAF sites that provides an interface for querying data via the `./api/form/query` endpoint. It provides features that improve user experience, such as processing large queries in smaller chunks, which helps avoid perceived slowdowns in web browsers.

## Methods

### `addTerm(id, operator, match, gate)`

Adds a new search term.

*   `id`: (string) The column ID to search. Must be one of the supported IDs listed below.
*   `operator`: (string) The comparison operator. Must be one of the supported operators listed below.
*   `match`: (string) The value to search for.
*   `gate`: (string, optional, default: "AND") The logical gate ("AND" or "OR") to combine with the next term.

| Supported IDs      | Supported Operators | Details |
|---------------|---------------------|-----------------------|
| recordID      | =, !=, >, >=, <, <=  |                    |
| recordIDs     | =                    | CSV list of recordIDs             |
| serviceID     | =, !=, >, >=, <, <=  |                    |
| submitted     | =, !=, >, >=, <, <=  | UNIX Timestamp                   |
| deleted       | =, !=, >, >=, <, <=  | UNIX Timestamp                   |
| title         | =, !=, >, >=, <, <=, LIKE, NOT LIKE | Wildcard: *              |
| userID        | =, !=  |                    |
| date          | =, <=, >             | UNIX Timetamp and also supports all [strtotime](https://www.php.net/manual/en/function.strtotime.php) formats  |
| dateInitiated | =, <=, >             | UNIX Timetamp and also supports all [strtotime](https://www.php.net/manual/en/function.strtotime.php) formats  |
| dateSubmitted | =, <=, >             | UNIX Timetamp and also supports all [strtotime](https://www.php.net/manual/en/function.strtotime.php) formats. E.g. dateSubmitted > 'last year' retrieves all records submitted within the last year  |
| categoryID    | =, !=                |                   |
| stepID        | =, !=                | submitted, notSubmitted, deleted, notDeleted, resolved, notResolved, actionable, or a numeric step ID |

### `addDataTerm(id, indicatorID, operator, match, gate)`

Adds a new search term specifically for data tables.

*   `id`: (string) Column ID or 'data' to search data table or 'dependencyID' to search records_dependencies data, matching on 'filled'. Must be one of the supported IDs listed below.
*   `indicatorID`: (string) Indicator ID or dependency ID. Use "0" to search all indicators.
*   `operator`: (string) The comparison operator. Must be one of the supported operators listed below.
*   `match`: (string) The value to search for.
*   `gate`: (string, optional, default: "AND") The logical gate ("AND" or "OR") to combine with the next term.

| Valid ID | Supported Operators | Details |
|---|---|---|
| data | =, !=, >, >=, <, <=, LIKE, NOT LIKE, MATCH, NOT MATCH, MATCH ALL |  |
| dependencyID | =, != |  |

### `importQuery(queryObject)`

Imports a query object generated by the Report Builder -> JSON -> JavaScript Template.

*   `queryObject`: (object) A JS object with representing a LEAF query.

**Example:**

```javascript
const queryData = {
  terms: [{id: 'stepID', operator: '=', match: 'notResolved'}],
  joins: ['status'],
  getData: [1, 2, 3]
};
formQuery.importQuery(queryData);
```
### `setLimit(offset, limit)`

Sets the query offset/limit based on MySQL offset and limit conventions.

*   `offset`: (number, default: 50) The offset based on the number of internal query matches. If `limit` is not specified provided this becomes the maximum number of results to return.
*   `limit`: (number, optional) The maximum number of results to return.

**Example:**

```javascript
formQuery.setLimit(100, 20); // Fast-forward 100 records, and get 20 records.
formQuery.setLimit(50); // Get the first 50 records
```
### `setLimitOffset(offset)`

Sets the query limit offset.

*   `offset`: (number, optional, default: 50) The offset based on the number of internal query matches.

**Example:**

```javascript
formQuery.setLimitOffset(25); // Skip the first 25 records
```
### `join(table)`

Adds a table to join to the query.

*   `table`: (string) The name of the table to join.

**Valid Options:**

*   `service`: Includes data related to the record's service
*   `status`: Includes the record's current status
*   `categoryName`: Includes the record's form type(s)
*   `categoryNameUnabridged`: Includes the record's form type(s), and also inactive forms
*   `recordsDependencies`: Includes data related to fulfilled requirements and their timestamps related to a record
*   `action_history`: Includes the record's history of actions
*   `stepFulfillment`: Includes fulfillment information related to workflow steps
*   `stepFulfillmentOnly`: Includes fulfillment information related to workflow steps, for steps that have been fulfilled
*   `recordResolutionData`: Include general resolution data
*   `recordResolutionBy`: Include data related to the individual who resolved a record
*   `initiatorName`: Include the record initiator's name
*   (Not implemented yet) `destructionDate`: 
*   `unfilledDependencies`: Include list of unfulfilled requirements

**Example:**

```javascript
formQuery.join('service'); // Join the services table
formQuery.join('status'); // Join the status table
```
### `getData(indicatorID)`

Includes data associated with an indicator ID in the result set.

*   `indicatorID`: (string|number|array) The indicator ID(s) to include.

**Example:**

```javascript
formQuery.getData(123); // Include data for indicator ID 123
formQuery.getData([1, 2, 3]); // Include data for indicator IDs 1, 2, and 3
```
### `sort(column, direction)`

Sorts the results.

*   `column`: (string, optional, default: "date") The column to sort by.
*   `direction`: (string, optional, default: "DESC") The sort direction ("ASC" or "DESC").

**Example:**

```javascript
formQuery.sort('date', 'ASC'); // Sort by date in ascending order
formQuery.sort('title'); // Sort by title in descending order (default)
```
### `updateTerm(id, operator, match, gate)`

Updates an existing search term.

*   `id`: (string) The column ID of the term to update.
*   `operator`: (string) The comparison operator.
*   `match`: (string) The new search term.
*   `gate`: (string) The logical gate.

**Example:**

```javascript
formQuery.updateTerm('title', '=', 'New Example Title', 'AND'); // Update the title term
```
### `updateDataTerm(id, indicatorID, operator, match, gate)`

Updates an existing data search term.

*   `id`: (string) The column ID of the term to update.
*   `indicatorID`: (string) The indicator ID.
*   `operator`: (string) The comparison operator.
*   `match`: (string) The new search term.
*   `gate`: (string) The logical gate.

**Example:**

```javascript
formQuery.updateDataTerm('data', 0, '=', 'New Data Value', 'AND'); // Update the data term
```
### `setExtraParams(params)`

Adds extra parameters to the end of the query API URL.

*   `params`: (string) The extra parameters to add.

**Example:**

```javascript
formQuery.setExtraParams('&x-filterData=title'); // data filter limits responses to only show titles
```
### `setRootURL(url)`

Sets the root URL for the API endpoint.

*   `url`: (string) The root URL.

**Example:**

```javascript
formQuery.setRootURL('https://api.example.com/VISN5/688/resources'); // Set the root URL
```
### `onSuccess(funct)`

Sets a success callback function.

*   `funct`: (function) The callback function to be called on success.  Receives `result`, `textStatus`, and `jqXHR` as arguments.

**Example:**

```javascript
formQuery.onSuccess(function(result) {
  console.log('Query successful:', result);
});
```
### `onProgress(funct)`

Sets a progress callback function.

*   `funct`: (function) The callback function to be called on each batch of data processed. Receives the progress (number of records processed) as an argument.

**Example:**

```javascript
formQuery.onProgress(function(progress) {
  console.log('Query progress:', progress);
});
```
### `setAbortSignal(signal)`

Sets an AbortSignal to cancel the query.

*   `signal`: (AbortSignal) The AbortSignal object.

**Example:**

```javascript
const abortController = new AbortController();
formQuery.setAbortSignal(abortController.signal);

// Later, to abort the query:
abortController.abort();
```
### `execute()`

Executes the query and returns a Promise resolving to the query response.

**Example:**

```javascript
formQuery.execute()
  .then(function(result) {
    console.log('Query result:', result);
  })
  .catch(function(error) {
    console.error('Query error:', error);
  });
```
