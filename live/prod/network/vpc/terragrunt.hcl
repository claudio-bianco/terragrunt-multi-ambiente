locals {
  repo_root = get_repo_root() # raiz do git repo
}

terraform {
  # Aponta para o módulo local no raiz do repo
  source = "${local.repo_root}/modules/vpc"
}

inputs = {
  cidr_block = "10.20.0.0/16" # exemplo para dev
}
