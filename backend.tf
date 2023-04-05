terraform {
  backend "azurerm" {
    resource_group_name = "rnd"
    storage_account_name = "tcastorageacc"
    container_name = "tcacontainer"
    key = "terraform2.tfstate"
  }


}