# This file was automatically generated by weform 0.53.0. Do not edit it
# manually.

# Used for CloudTrail auditing. If Terraform is executed by a user from their
# laptop, CloudTrail will show a "manual" session with a trail to the related
# AWS IAM user. This can be overridden when Travis runs Terraform to include
# Travis-specific information such build number and git repository.
variable aws_session_name {
  default = "manual"
}

### State
terraform {
  backend "s3" {}

  required_version = "~> 0.12.0"
}

### Providers
provider "aws" {
  region  = local.region
  profile = var.aws_profile

  assume_role {
    role_arn     = "arn:aws:iam::${local.workspace_account}:role/${var.assumed_role}"
    session_name = var.aws_session_name
  }

  version = "2.16.0"
}

provider "aws" {
  alias   = "eu-west-1"
  region  = "eu-west-1"
  profile = var.aws_profile

  assume_role {
    role_arn = "arn:aws:iam::${local.workspace_account}:role/${var.assumed_role}"
  }

  version = "2.16.0"
}

provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  profile = var.aws_profile

  assume_role {
    role_arn = "arn:aws:iam::${local.workspace_account}:role/${var.assumed_role}"
  }

  version = "2.16.0"
}

# This provider is intended to be used internally by weform-generated files in
# order to be compatible with plat workspaces. The Platform account is unlike
# the standard environment accounts (e.g. dev, stag, prod) certificates and
# Route53 zones are not setup/available. Therefore when in a plat workspace, we
# lookup those resources from the prod account.
provider "aws" {
  alias   = "weform_data_source_provider"
  region  = local.region
  profile = var.aws_profile

  assume_role {
    role_arn     = "arn:aws:iam::${local.__weform_data_source_account_id}:role/${var.assumed_role}"
    session_name = var.aws_session_name
  }

  version = "2.16.0"
}