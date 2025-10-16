# live/dev/terragrunt.hcl
locals { env = "dev" }

inputs = {
  environment = local.env
}
