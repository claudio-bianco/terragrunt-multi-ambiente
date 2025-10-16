# live/prod/terragrunt.hcl
locals { env = "prod" }

inputs = {
  environment = local.env
}
