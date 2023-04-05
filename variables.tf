variable "clientsec" {
  type        = string
  default     = "Qbf8Q~m6P_uaIwkU6aYyCZsDqOXU4qP1Kl2dZb4B"
  description = "cs name"
}


variable "resource_group_location" {
  type        = string
  default     = "australiaeast"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}


#--- VM image specs
variable "linux_vm_image_publisher" {
  type        = string
  description = "Virtual machine source image publisher"
  default     = "OpenLogic"
}
variable "linux_vm_image_offer" {
  type        = string
  description = "Virtual machine source image offer"
  default     = "CentOS"
}

variable "centos_7_gen2_sku" {
  type        = string
  description = "SKU for latest CentOS 8 Gen2"
  default     = "7_9-gen2"
}
variable "centos_8_sku" {
  type        = string
  description = "SKU for latest CentOS 8 "
  default     = "8_5"

}

