resource "azurerm_virtual_network" "virtual_network" {
  name                = "${local.general_name}-${var.virtual_network.network_name}"
  resource_group_name = azurerm_resource_group.dev_group.name
  location            = azurerm_resource_group.dev_group.location
  address_space       = var.virtual_network.address_space

  tags = merge(local.tags, var.virtual_network.tags)
}

resource "azurerm_subnet" "subnet" {
  name                 = "${local.general_name}-${var.subnet.name}"
  resource_group_name  = azurerm_resource_group.dev_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = var.subnet.address_prefixes
}
