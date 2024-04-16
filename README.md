# Terraform Azurerm with K3s Install on Single Node

## Prerequisite

1. [Terraform](https://spacelift.io/blog/how-to-install-terraform) Installed

2. Generate a pair of SSH Key - [Reference](https://docs.oracle.com/en/cloud/cloud-at-customer/occ-get-started/generate-ssh-key-pair.html#GUID-8B9E7FCB-CEA3-4FB3-BF1A-FD3406A2432F)

3. An Azure Cloud account with Service Principal created - [Reference](https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-service-principal-portal) or [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/azure-cli-sp-tutorial-1?tabs=bash)

## Notes

1. The Linux VM is using Ubuntu-22.04 as base image.
2. Please be aware that the Network Ingress is config to accept all source of IP address.

## Steps to utilize the script at Local Machine

1. Export credentials to your terminal environment

    ```bash
        export ARM_SUBSCRIPTION_ID=<"Subscription ID of your target Azure Subscription">
        export ARM_TENANT_ID=<"Directory (Tenant) ID from Service Principal">
        export ARM_CLIENT_ID=<"Application (Client) ID from Service Principal">
        export ARM_CLIENT_SECRET=<"Secret generated from Service Principal">
    ```

    or 

    ```powershell
        $env:ARM_SUBSCRIPTION_ID="Subscription ID of your target Azure Subscription"
        $env:ARM_TENANT_ID="Directory (Tenant) ID from Service Principal"
        $env:ARM_CLIENT_ID="Application (Client) ID from Service Principal"
        $env:ARM_CLIENT_SECRET="Secret generated from Service Principal"
    ```

<br>

2. Export SSH Key Path to your terminal environment

    ```bash
        export TF_VAR_public_key_file_path=<Path to your SSH Public Key>
        export TF_VAR_private_key_file_path=<Path to your SSH Private Key>
    ```

    ```powershell
       $env:TF_VAR_public_key_file_path="Path to your SSH Public Key"
        $env:TF_VAR_private_key_file_path="Path to your SSH Private Key"
    ```


<br>

3. Change the remote backend values to match your needs
    - Create a Storage account on Azure Portal
    - Create a Container
    - **Notes:** If you want to use local state, just comment out the backend config block at **$PWD/examples/basic/terraform.tf**

<br>

4. Run the script below to create your K3s VM

    ```bash
        cd ./deployments/k3s
        terraform init -upgrade
        terraform plan
        terraform apply
    ```

<br>

5. After run successfully, export KUBECONFIG with the k3s_config files

    - You will be able to see the files showed in **./deployments/k3s**

    ```bash
        export KUBECONFIG=./k3s_config
    ```
