module "deployment" {
  source = "../../"

  general = {
    deployment_name = "k3sService-dev"
    location        = "SouthEast Asia"
    general_tags = {
      env   = "dev"
      owner = "k3sService"
    }
  }

  virtual_network = {
    network_name  = "network"
    address_space = ["10.126.0.0/16"]
    tags = {
      network = "public"
    }
  }

  subnet = {
    name             = "subnet"
    address_prefixes = ["10.126.1.0/24"]
  }

  linux_vm = {
    "linux-vm" = {
      size                  = "Standard_DS2_v2"
      admin_username        = "k3sService"
      custom_data_file_path = "../../bash/k3s_install.sh"

      admin_ssh_key = {
        username              = "k3sService"
        public_key_file_path  = var.public_key_file_path
        private_key_file_path = var.private_key_file_path
      }

      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }

      source_image_reference = {
        offer     = "0001-com-ubuntu-server-jammy"
        publisher = "Canonical"
        sku       = "22_04-lts-gen2"
        version   = "latest"
      }

      tags = {}
    }
  }
}

