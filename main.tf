locals {
  general_name = var.general.deployment_name
  location     = var.general.location
  tags         = var.general.general_tags
}

resource "azurerm_resource_group" "dev_group" {
  name     = local.general_name
  location = local.location
  tags     = local.tags
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  for_each = var.linux_vm

  name                  = "${local.general_name}-${each.key}"
  resource_group_name   = azurerm_resource_group.dev_group.name
  location              = azurerm_resource_group.dev_group.location
  size                  = each.value.size
  admin_username        = each.value.admin_username
  network_interface_ids = [azurerm_network_interface.network_interface[each.key].id]

  admin_ssh_key {
    username   = each.value.admin_ssh_key.username
    public_key = file(each.value.admin_ssh_key.public_key_file_path)
  }

  os_disk {
    caching              = each.value.os_disk.caching
    storage_account_type = each.value.os_disk.storage_account_type
  }

  source_image_reference {
    offer     = each.value.source_image_reference.offer
    publisher = each.value.source_image_reference.publisher
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }

  tags = merge(local.tags, each.value.tags)
}

resource "null_resource" "k3s_setup" {
  for_each = var.linux_vm

  triggers = {
    public_ip_address = join(",", [azurerm_linux_virtual_machine.linux_vm[each.key].public_ip_address])
  }

  connection {
    type        = "ssh"
    user        = each.value.admin_ssh_key.username
    host        = azurerm_linux_virtual_machine.linux_vm[each.key].public_ip_address
    private_key = file(each.value.admin_ssh_key.private_key_file_path)
  }

  provisioner "file" {
    source      = "${path.module}/bash"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bash/k3s_install.sh",
      "/tmp/bash/k3s_install.sh ${azurerm_linux_virtual_machine.linux_vm[each.key].public_ip_address}"
    ]
  }

  provisioner "local-exec" {
    command = templatefile("${path.module}/template/get_kube_config.sh", {
      public_ip    = azurerm_linux_virtual_machine.linux_vm[each.key].public_ip_address
      user         = each.value.admin_username
      identityFile = each.value.admin_ssh_key.private_key_file_path
    })
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "azurerm_network_interface" "network_interface" {
  for_each = var.linux_vm

  name                = "${local.general_name}-${each.key}-nic"
  resource_group_name = azurerm_resource_group.dev_group.name
  location            = azurerm_resource_group.dev_group.location

  ip_configuration {
    name                          = "external"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[each.key].id
    primary                       = true
  }

  tags = merge(local.tags, {
    vm = "${local.general_name}-${each.key}"
  })
}

resource "azurerm_public_ip" "public_ip" {
  for_each = var.linux_vm

  name                = "${local.general_name}-${each.key}-public-ip"
  resource_group_name = azurerm_resource_group.dev_group.name
  location            = azurerm_resource_group.dev_group.location
  allocation_method   = "Dynamic"

  tags = merge(local.tags, {
    vm = "${local.general_name}-${each.key}"
  })
}

# Bind the security group to the subnet
resource "azurerm_subnet_network_security_group_association" "network_association" {
  for_each = var.linux_vm

  network_security_group_id = azurerm_network_security_group.security_group[each.key].id
  subnet_id                 = azurerm_subnet.subnet.id
}

resource "azurerm_network_security_group" "security_group" {
  for_each = var.linux_vm

  name                = "${local.general_name}-${each.key}-security-group"
  resource_group_name = azurerm_resource_group.dev_group.name
  location            = azurerm_resource_group.dev_group.location
}

resource "azurerm_network_security_rule" "allow_tcp" {
  for_each = var.linux_vm

  resource_group_name         = azurerm_resource_group.dev_group.name
  network_security_group_name = azurerm_network_security_group.security_group[each.key].name
  name                        = "AllowedTCP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "allow_all_outbound" {
  for_each = var.linux_vm

  resource_group_name         = azurerm_resource_group.dev_group.name
  network_security_group_name = azurerm_network_security_group.security_group[each.key].name
  name                        = "AllowedAllOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

