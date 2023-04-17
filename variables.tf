variable "resource_alias" {
  description = "terraform-jenkins"
  type        = string
  default     = "terraform-jenkins"
}

variable "vpc_cider" {
        default = "10.0.0.0/16"
}

variable "subnets_cidr" {
  type = list
  default = ["10.2.1.0/24", "10.2.2.0/24"]
}

variable "azs" {
	type = list
	default = ["eu-east-2a", "us-east-2b"]
}

variable "vpc_private_subnets" {
  type    = list
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc_public_subnets" {
  type    = list
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "secret_dev_credentials" {
  type = string
}

variable "secret_prod_credentials" {
  type = string
}
