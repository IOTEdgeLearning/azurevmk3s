variable "general" {
  type = object({
    deployment_name = string
    general_tags    = map(string)
    location        = string
  })
  description = <<EOF
    General input to define the deployment
    deployment_name : The name of the deployment
    location        : The location (region) of deployment
    general_tags    : The tags for assign to each of the available resources, would be use to combine with any additional tags
  EOF
}

variable "virtual_network" {
  type = object({
    network_name  = string
    address_space = list(string)
    tags          = map(string)
  })
}

variable "subnet" {
  type = object({
    name             = string
    address_prefixes = list(string)
  })
}

variable "linux_vm" {
  type = map(object({
    size                  = string
    admin_username        = string
    custom_data_file_path = string
    admin_ssh_key = object({
      username              = string
      public_key_file_path  = string
      private_key_file_path = string
    })

    os_disk = object({
      caching              = string
      storage_account_type = string
    })

    source_image_reference = object({
      offer     = string
      publisher = string
      sku       = string
      version   = string
    })

    tags = map(string)
  }))
}
