terraform {
  source = "../../../modules/vpc"
}

inputs = {
  cidr_block = "10.20.0.0/16"
}
