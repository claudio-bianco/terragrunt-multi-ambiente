# terragrunt.hcl (raiz)
# Padrões, remote state e inputs comuns

locals {
  aws_region = get_env("AWS_REGION", "us-east-1")
  project    = "acme"
}

# Backend remoto por ambiente (S3 + DynamoDB)
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.auto.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "${local.project}-tfstate-${get_env("ACCOUNT_ID")}-${local.aws_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "${local.project}-tf-locks-${get_env("ACCOUNT_ID")}-${local.aws_region}"
    encrypt        = true
  }
}

# Terraform comum
terraform {
  extra_arguments "defaults" {
    commands = get_terraform_commands_that_need_vars()
    arguments = [
      "-input=false",
      "-lock=true",
      "-no-color",
    ]
  }
}

# Incluir hcl do ambiente
include "root" {
  path = find_in_parent_folders("env.hcl", "ignore")
  expose = true
}
