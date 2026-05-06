resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "koorevaar-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "env" {
  name                       = "koorevaar-env"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

# ==================== LLM Adapter (Internal) ====================
resource "azurerm_container_app" "llm_adapter" {
  name                         = "llm-adapter"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "llm-adapter"
      image  = "${var.dockerhub_username}/llm-adapter:${var.image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "CF_ACCOUNT_ID"
        value = var.cf_account_id
      }
      env {
        name        = "CF_API_TOKEN"
        secret_name = "cf-api-token"
      }
    }
  }

  ingress {
    external_enabled = false
    target_port      = 8080
    transport        = "http"
  }

  secret {
    name  = "cf-api-token"
    value = var.cf_api_token
  }
}

# ==================== Text Intelligence API (Public) ====================
resource "azurerm_container_app" "text_api" {
  name                         = "text-intelligence-api"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "api"
      image  = "${var.dockerhub_username}/text-intelligence-api:${var.image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "OLLAMA_URL"
        value = "https://your-ollama-proxy.yourusername.workers.dev"   # ← Change this
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    transport        = "http"
  }
}

output "api_fqdn" {
  value = azurerm_container_app.text_api.ingress[0].fqdn
}

output "adapter_internal_url" {
  value = "http://llm-adapter"
}
