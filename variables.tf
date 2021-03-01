# Azure credentials
# https://learn.hashicorp.com/tutorials/terraform/azure-remote?in=terraform/azure-get-started#configure-a-service-principal

variable "azure_subscription_id" {
  description = "Azure subscription id, obtained as `SUBSCRIPTION_ID` when running `az account list`."
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure tenant id, obtained as `tenant` when creating a service principal."
  type        = string
}

variable "azure_client_id" {
  description = "Azure client ID, obtained as `appID` when creating a service principal."
  type        = string
}

variable "azure_client_secret" {
  description = "Azure client secret, obtained as `password` when creating a service principal."
  type        = string
  sensitive   = true
  # ^ mark the client secret as sensitive to prevent it from accidentally showing up in logs
}

variable "azure_ad_admin" {
  description = "login username of the Azure Active Directory administrator account"
  type        = string
  sensitive   = true # just in case
  default     = "AzureAD Admin"
}

# https://azure.microsoft.com/en-us/global-infrastructure/geographies/#choose-your-region
variable "azurerm_region" {
  description = "Azure region"
  type        = string
  # region `westeurope` is located in the Netherlands
  default = "westeurope"
}

variable "environment" {
  description = "name of the environment"
  type        = string
  default     = "dev"
}

variable "emails" {
  description = "a list of email addresses to send notifications to"
  type        = list(string)
  default     = []
}

variable "mssql_password" {
  description = "MS SQL Server password"
  type        = string
  sensitive   = true
}

variable "mysql_password" {
  description = "MySQL Server password"
  type        = string
  sensitive   = true
}

variable "mongo_shard_key" {
  description = "The name of the key to partition MongoDB on for sharding. There must not be any other unique index keys."
  type        = string
}
