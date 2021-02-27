variable "terraform_org" {
  description = "name of the Terraform Cloud organization"
  type        = string
  # personal account, should be a company account for real-life scenarios!
  default = "cinerealkiara"
}

variable "terraform_workspace" {
  description = "name of the workspace in Terraform Cloud. it will be created automatically if not present."
  type        = string
  default     = "sentia-assignment"
}
