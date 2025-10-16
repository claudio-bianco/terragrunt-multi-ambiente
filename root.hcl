locals {
  project     = get_env("PROJECT", "acme")
  # Deriva o ambiente pela estrutura: live/<env>/<stack>/<componente>
  # Ex.: get_original_terragrunt_dir() = .../live/dev/network/vpc
  # dirname(...)                       = .../live/dev/network
  # dirname(dirname(...))              = .../live/dev
  # basename(...)                      = "dev"
  environment = basename(dirname(dirname(get_original_terragrunt_dir())))
  # Mapa de regiões por ambiente
  region_map = {
    dev  = "us-east-1"
    prod = "us-east-2"
  }
  aws_region = try(local.region_map[local.environment], get_env("AWS_REGION", "us-east-1"))
  # aws_region  = get_env("AWS_REGION", "us-east-1")
  # Descobre a conta automaticamente (ou usa var de ambiente se existir)
  account_id  = get_env("ACCOUNT_ID", get_aws_account_id())
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
