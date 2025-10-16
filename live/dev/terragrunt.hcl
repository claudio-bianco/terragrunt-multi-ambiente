include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals { env = "dev" }

inputs = {
  environment = local.env
}
