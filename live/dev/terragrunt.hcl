include "root" {
  path = find_in_parent_folders()  # sobe até o terragrunt.hcl da raiz do repo
}

locals { env = "dev" }

inputs = {
  environment = local.env
}
