terraform {
  source = "../../../modules/vpc"
}

inputs = {
  env        = "prod"
  cidr_block = "10.20.0.0/16"
}
