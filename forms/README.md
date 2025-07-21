# API (v1) Quick Overview
The LEAF API provides programmatic read and write access over HTTPS using a Representational State Transfer (REST) pattern.

All actions involving a write operation require a secret token to prevent Cross Site Request Forgery (CSRF). This token is provided as a template variable on LEAF sites. The syntax is:
```
<!--{$CSRFToken}-->
```

## Conventions and terminology
- Retrieving data is a "GET" request
- Writing data is a "POST" request
- Depending on context, some terminology may be used interchangeably:
  - Record / Request / Form refers to items that individuals input into the system
  - Form may also refer to items that administrators configure in the Form Editor
  - Field / Indicator may refer to an individual data element within a record

## Common APIs
The following is a list of commonly used APIs, their parameters, and examples of use.


### Records ([api/form](https://github.com/department-of-veterans-affairs/LEAF/blob/master/LEAF_Request_Portal/api/controllers/FormController.php))

#### Create a new record
POST api/form/new ([Example](https://github.com/department-of-veterans-affairs/LEAF-Developer-Examples/blob/master/forms/create_new_request.tpl))

  ```
  CSRFToken       string (required)
  numform_FORM_ID 1      (required) Replace FORM_ID with the form ID
  FIELD_ID        string (optional) Replace FIELD_ID with the field ID, used to prepopulate a record
  ...
  FIELD_ID                          Many FIELD_IDs can be added simultaneously
  service         number (optional) Service ID
  title           string (optional)
  priority        number (optional)
  ```

#### Read one or more records
GET api/form/query (Example in Report Builder -> JSON -> JavaScript Template)

See https://github.com/department-of-veterans-affairs/LEAF-Developer-Examples/blob/master/forms/formQuery.md

#### Update the contents of a field within a record
POST api/form/[recordID] ([Example](https://github.com/department-of-veterans-affairs/LEAF-Developer-Examples/blob/master/forms/custom_fields/copy_orgchart_employee_selection_to_other_field.md)
)
  ```
  CSRFToken      string (required)
  FIELD_ID       string (optional) Replace FIELD_ID with the field ID
  ...
  FIELD_ID                         Many FIELD_IDs can be added simultaneously
  ```
  Special considerations: The "grid" input format expects data to be formatted as in [this example](https://github.com/department-of-veterans-affairs/LEAF-Developer-Examples/blob/master/forms/update_grid_formatted_field.tpl).

#### Cancel a record
POST api/form/[recordID]/cancel ([Example](https://github.com/department-of-veterans-affairs/LEAF-Developer-Examples/blob/master/forms/cancel_request.md))
  ```
  CSRFToken      string (required)
  comment        string (optional)
  ```

### Workflow for a record ([api/formWorkflow](https://github.com/department-of-veterans-affairs/LEAF/blob/master/LEAF_Request_Portal/api/controllers/FormWorkflowController.php))

#### Apply an action to a record
POST api/formWorkflow/[recordID]/apply
  ```
  CSRFToken      string (required)
  dependencyID   int    (required) This is the ID of the requirement for the step that the record is currently on
  actionType     string (required) This is the ID of the action that will be applied
  comment        string (optional) For automated actions, it's good practice to briefly explain the purpose of the automation
  ```
