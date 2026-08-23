variable "logic_app_name" {
  type        = string
  description = "Name of the logic app"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "resource_location" {
  type        = string
  description = "Azure region for the resource group"
}

variable "resource_tags" {
  type        = map(string)
  description = "Tags for the resource group"
}

variable "workflow_definition" {
  type        = string
  description = "JSON string containing the Logic App workflow definition"
  default     = ""
}

variable "workflow_schema" {
  type        = string
  description = "Workflow schema version"
  default     = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
}

variable "workflow_version" {
  type        = string
  description = "Workflow content version"
  default     = "1.0.0.0"
}

variable "workflow_parameters" {
  type        = map(any)
  description = "Workflow parameters for connections"
  default     = {}
}

variable "function_app_id" {
  type        = string
  description = "The ID of the Function App for Logic App actions"
  default     = ""
}

variable "quarantine_function_name" {
  type        = string
  description = "Name of the quarantine function"
  default     = "QuarantineFunction"
}

variable "validator_function_name" {
  type        = string
  description = "Name of the file validator function"
  default     = "FileValidatorFunction"
}

variable "upload_function_name" {
  type        = string
  description = "Name of the upload to permanent function"
  default     = "UploadToPermanentFunction"
}

variable "fallback_function_name" {
  type        = string
  description = "Name of the fallback function"
  default     = "FallbackFunction"
}

variable "blob_container_name" {
  type        = string
  description = "Name of the blob container to monitor"
  default     = "fleet-quarantine-container"
}

variable "storage_account_connection_string" {
  type        = string
  description = "Storage account connection string for blob trigger"
  default     = ""
  sensitive   = true
}