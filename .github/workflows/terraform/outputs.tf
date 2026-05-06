output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "container_app_environment_name" {
  value = azurerm_container_app_environment.env.name
}

output "text_intelligence_api_url" {
  value = "https://${azurerm_container_app.text_api.ingress[0].fqdn}"
}

output "llm_adapter_internal_url" {
  value = "http://llm-adapter"
}

output "important_notes" {
  value = "Update OLLAMA_URL in the text_api container with your Cloudflare Worker URL"
}
