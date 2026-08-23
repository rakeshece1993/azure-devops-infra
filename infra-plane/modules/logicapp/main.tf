locals {
  # Build the workflow definition dynamically with Function App IDs
  workflow_with_functions = var.function_app_id != "" ? jsonencode({
    "$schema"      = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
    contentVersion = "1.0.0.0"
    actions = {
      Call_to_Quarantine = {
        type = "Function"
        inputs = {
          method = "POST"
          body = {
            blobName       = "@triggerBody()?['name']"
            blobProperties = "@triggerBody()?['properties']"
            containerName  = "@triggerBody()?['containerInfo']?['name']"
          }
          function = {
            id = "${var.function_app_id}/functions/${var.quarantine_function_name}"
          }
        }
        runAfter = {}
      }
      Call_to_fileValidator = {
        type = "Function"
        inputs = {
          method = "POST"
          body   = "@body('Call_to_Quarantine')"
          function = {
            id = "${var.function_app_id}/functions/${var.validator_function_name}"
          }
        }
        runAfter = {
          Call_to_Quarantine = ["SUCCEEDED"]
        }
      }
      Is_File_Valid = {
        type = "If"
        expression = {
          and = [
            {
              equals = [
                "@outputs('Call_to_fileValidator')?['statusCode']",
                200
              ]
            }
          ]
        }
        actions = {
          Call_UploadToPermanent = {
            type = "Function"
            inputs = {
              method = "POST"
              body   = "@body('Call_to_Quarantine')"
              function = {
                id = "${var.function_app_id}/functions/${var.upload_function_name}"
              }
            }
          }
        }
        else = {
          actions = {
            Call_fallback = {
              type = "Function"
              inputs = {
                method = "POST"
                body   = "@body('Call_to_fileValidator')"
                function = {
                  id = "${var.function_app_id}/functions/${var.fallback_function_name}"
                }
              }
            }
          }
        }
        runAfter = {
          Call_to_fileValidator = ["SUCCEEDED"]
        }
      }
    }
    outputs  = {}
    triggers = {
      When_a_blob_is_added_or_updated = {
        type = "ApiConnection"
        inputs = {
          host = {
            connection = {
              name = "@parameters('$connections')['azureblob']['connectionId']"
            }
          }
          method = "get"
          path   = "/v2/datasets/default/triggers/batch/onupdatedfile"
          queries = {
            folderId        = var.blob_container_name
            maxFileCount    = 10
            checkBothCreatedAndModifiedDateTime = false
          }
        }
        recurrence = {
          frequency = "Minute"
          interval  = 1
        }
      }
    }
  }) : jsonencode({
    "$schema"      = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
    contentVersion = "1.0.0.0"
    triggers       = {}
    actions        = {}
    outputs        = {}
  })
}

resource "azurerm_logic_app_workflow" "logic_app" {
  name                = var.logic_app_name
  location            = var.resource_location
  resource_group_name = var.resource_group_name
  tags                = var.resource_tags
}

# Deploy the workflow definition using ARM template (only if function_app_id is provided)
resource "azurerm_resource_group_template_deployment" "logic_app_definition" {
  count               = var.function_app_id != "" ? 1 : 0
  name                = "${var.logic_app_name}-definition"
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"

  template_content = jsonencode({
    "$schema"      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
    contentVersion = "1.0.0.0"
    resources = [
      {
        type       = "Microsoft.Logic/workflows"
        apiVersion = "2019-05-01"
        name       = var.logic_app_name
        location   = var.resource_location
        tags       = var.resource_tags
        properties = {
          state      = "Enabled"
          definition = jsondecode(local.workflow_with_functions)
        }
      }
    ]
  })

  depends_on = [azurerm_logic_app_workflow.logic_app]
}