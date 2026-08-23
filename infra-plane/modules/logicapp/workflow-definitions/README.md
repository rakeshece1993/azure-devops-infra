# Logic App Workflow Definitions

This directory contains JSON workflow definitions for Azure Logic Apps.

## Available Workflows

### blob-processing-workflow.json
Processes blob uploads with the following steps:
1. **Trigger**: When a blob is added or updated in `fleet-quarantine-container`
2. **Call_to_Quarantine**: Calls Azure Function to quarantine the blob
3. **Call_to_fileValidator**: Validates the file
4. **Is_File_Valid**: Conditional check
   - If valid (200): Calls `UploadToPermanent` function
   - If invalid: Calls `fallback` function

## How to Use

### Option 1: Use existing workflow
```hcl
module "logic_app_workflow" {
  source              = "../../modules/logicapp"
  logic_app_name      = "my-logic-app"
  resource_group_name = "my-rg"
  resource_location   = "eastus"
  
  # Load workflow from file
  workflow_definition = file("${path.module}/../../modules/logicapp/workflow-definitions/blob-processing-workflow.json")
}
```

### Option 2: Create custom workflow
1. Create a new JSON file in this directory
2. Follow the Azure Logic App workflow schema
3. Reference it in your Terraform configuration

## Workflow Schema
All workflows must follow the Azure Logic App schema:
```
https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#
```

## Notes
- Connection names (e.g., `azureFunctionOperation-4`) need to be configured separately
- Service provider connections (like AzureBlob) require API connections to be set up
- You may need to create API connections manually or via Terraform before deploying workflows

