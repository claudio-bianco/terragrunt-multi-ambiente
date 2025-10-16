terraform {
  source = "../../../modules/vpc"
}

inputs = {
  env        = "dev"
  cidr_block = "10.10.0.0/16"
}
