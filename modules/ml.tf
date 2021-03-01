resource "azurerm_container_registry" "acr" {
  name                = "${local.prefix}acr" # alphanumeric
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic" # Basic -> Standard -> Premium
  admin_enabled       = false
  tags                = local.default_tags
  # georeplication_locations = ["East US"] # Premium, don't list `location`
  # retention_policy = [] # Premium
  # trust_policy     = [] # Premium
  # network_rule_set = [] # Premium
}

resource "azurerm_machine_learning_workspace" "mlws" {
  name                    = "${local.prefix}-mlws"
  description             = "Azure Machine Learning Workspace"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  application_insights_id = azurerm_application_insights.ai.id
  key_vault_id            = azurerm_key_vault.keyvault.id
  storage_account_id      = azurerm_storage_account.sa.id
  high_business_impact    = false   # reduce diagnostic data collected by the service
  sku_name                = "Basic" # Basic -> Enterprise
  container_registry_id   = azurerm_container_registry.acr.id
  tags                    = local.default_tags
  # discovery_url = ""

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_cognitive_account" "cognitive" {
  for_each            = var.cognitive_services
  name                = "${local.prefix}-cognitive"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  # https://docs.microsoft.com/en-us/azure/cognitive-services/cognitive-services-apis-create-account-cli?tabs=linux#create-a-cognitive-services-resource
  # Academic, AnomalyDetector, Bing.Autosuggest, Bing.Autosuggest.v7, Bing.CustomSearch, Bing.Search, Bing.Search.v7, Bing.Speech, Bing.SpellCheck, Bing.SpellCheck.v7, CognitiveServices, ComputerVision, ContentModerator, CustomSpeech, CustomVision.Prediction, CustomVision.Training, Emotion, Face, FormRecognizer, ImmersiveReader, LUIS, LUIS.Authoring, Personalizer, QnAMaker, Recommendations, SpeakerRecognition, Speech, SpeechServices, SpeechTranslation, TextAnalytics, TextTranslation, WebLM
  kind = each.key
  # https://azure.microsoft.com/en-us/pricing/details/cognitive-services/
  # F0, F1, S, S0, S1, S2, S3, S4, S5, S6, P0, P1, P2
  sku_name = each.value
  # qna_runtime_endpoint = ""
  tags = local.default_tags
}

# application insights

resource "azurerm_application_insights" "ai" {
  name                = "${local.prefix}-ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  tags                = local.default_tags
}
