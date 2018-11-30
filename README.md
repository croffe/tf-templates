# tf-templates
Terraform Templates for testing

## Azure -  Cloud Shell Terraform Demo
In the first demo - the Azure template will prompt you for a machine prefix name, and will then create the resources related to your VM.

### Requirements
- Azure CLI
- Terraform
- Microsoft Azure Storage Explorer (optional)

### Steps to run the Azure demo
The demo can be run using Terraform from your local machine, or through Azure Cloud shell. To use it from your local machine, you need to az login to your account, or you can add your login details to the azurerm provider.

Instead, I recommend you try this demo from the Azure Cloud Shell.  The Azure Cloud Shell will handle your credentials transparently.

#### Using Azure Cloud Shell

- Upload this repository to your cloud shell folder using File Explorer
- Log in to your account, and click on the Azure Cloud shell icon.
- cd to ```tf-templates/azurerm/singleton-linux``` folder
- Run ```terraform init``` to install the azurerm provider
- Run ```terraform plan``` to see what will change
- Run ```terraform apply``` to run the changes
- Verify the resources have been created in Azure
