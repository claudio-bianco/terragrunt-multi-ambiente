variable "environment" {
  type        = string
  description = "Environment name (dev|prod)"
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR"
}
