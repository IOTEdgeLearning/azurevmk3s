output "ssh_vm_details" {
  value = {
    for key, value in var.linux_vm : key => {
      access_ip = format("%s@%s", value.admin_username, azurerm_linux_virtual_machine.linux_vm[key].public_ip_address)
    }
  }
}
