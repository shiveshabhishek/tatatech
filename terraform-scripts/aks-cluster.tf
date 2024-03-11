provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "tatatech-rg"
  location = "East US"

  tags = {
    environment = "TataTech"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "tatatech-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

# Subnet 1
resource "azurerm_subnet" "my_terraform_aks_subnet" {
  name                 = "aksSubnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Subnet 2
resource "azurerm_subnet" "my_terraform_other_subnet" {
  name                 = "otherSubnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "tatatech-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "tatatech-k8s"
  kubernetes_version  = "1.27.9"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_B2s"
    os_disk_size_gb = 30

    vnet_subnet_id = azurerm_subnet.my_terraform_aks_subnet.id
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }
  
  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "TataTech"
  }
}