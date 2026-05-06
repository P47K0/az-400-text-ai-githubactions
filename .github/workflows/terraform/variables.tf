variable "location" {
  description = "Azure region"
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Resource Group name"
  default     = "koorevaar-rg"
}

variable "dockerhub_username" {
  description = "Your Docker Hub username"
  type        = string
}

variable "image_tag" {
  description = "Image tag to use (latest or specific tag)"
  default     = "latest"
}

variable "cf_account_id" {
  description = "Cloudflare Account ID"
  type        = string
  sensitive   = true
}

variable "cf_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}
