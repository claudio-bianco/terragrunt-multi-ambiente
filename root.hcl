locals {
  project     = get_env("PROJECT", "acme")
  aws_region  = get_env("AWS_REGION", "us-east-1")
  # Descobre a conta automaticamente (ou usa var de ambiente se existir)
  account_id  = get_env("ACCOUNT_ID", get_aws_account_id())
  # tenta descobrir o ambiente a partir da variável de input ou da estrutura do path
  environment = try(local.env, basename(dirname(get_terragrunt_dir())))
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.auto.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "${local.project}-tfstate-${local.account_id}-${local.aws_region}"
    # path customizado por ambiente:
    key            = "states/${local.environment}/terraform.tfstate"
    # key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "${local.project}-tf-locks-${local.account_id}-${local.aws_region}"
    encrypt        = true
  }
}

terraform {
  extra_arguments "defaults" {
    commands  = get_terraform_commands_that_need_vars()
    arguments = ["-input=false", "-lock=true", "-no-color"]
  }
}
