# Azure credentials
# https://learn.hashicorp.com/tutorials/terraform/azure-remote?in=terraform/azure-get-started#configure-a-service-principal

variable "azure_subscriptionid" {
  description = "Azure subscription id, obtained as `SUBSCRIPTION_ID` when running `az account list`."
  type        = string
}

variable "azure_tenantid" {
  description = "Azure tenant id, obtained as `tenant` when creating a service principal."
  type        = string
}

variable "azure_clientid" {
  description = "Azure client ID, obtained as `appID` when creating a service principal."
  type        = string
}

variable "azure_clientsecret" {
  description = "Azure client secret, obtained as `password` when creating a service principal."
  type        = string
  sensitive   = true
}
