# This file was automatically generated by weform 0.53.0. Do not edit it
# manually.

# NOTE: If you are adding a data source to this file and intend for that data
# source to be discoverable in a plat or users workspace even though the resource does
# not exist in the plat or users account, then set the provider attribute value to
# `aws.weform_data_source_provider`.

data "aws_ami" "base" {
  provider    = aws.weform_data_source_provider
  owners      = values(local.aws_accounts)
  most_recent = true

  filter {
    name   = "name"
    values = ["wt_v3_docker*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_acm_certificate" "wetransfer" {
  provider = aws.weform_data_source_provider
  domain   = local.wetransfer_tld
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "wetransfer" {
  provider     = aws.weform_data_source_provider
  name         = local.wetransfer_tld
  private_zone = false
}

data "aws_acm_certificate" "wetransfernet" {
  provider = aws.weform_data_source_provider
  domain   = local.wetransfer_net_tld
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "wetransfernet" {
  provider     = aws.weform_data_source_provider
  name         = local.wetransfer_net_tld
  private_zone = false
}

data "aws_subnet_ids" "private" {
  vpc_id   = data.aws_vpc.base.id
  provider = aws.weform_data_source_provider

  tags = {
    Zone = "private"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id   = data.aws_vpc.base.id
  provider = aws.weform_data_source_provider

  tags = {
    Zone = "public"
  }
}

data "aws_security_group" "default" {
  vpc_id   = data.aws_vpc.base.id
  provider = aws.weform_data_source_provider

  # 'default' is a protected name so it will always return
  name = "default"
}

data "aws_security_group" "v2_access" {
  vpc_id   = data.aws_vpc.base.id
  provider = aws.weform_data_source_provider

  tags = {
    tf-v2-access = "true"
  }
}

data "aws_vpc" "base" {
  filter {
    name   = "tag:tfservice"
    values = ["base"]
  }

  provider = aws.weform_data_source_provider

  filter {
    name   = "tag:tfworkspace"
    values = [local.vpc_tags_prefix]
  }
}

data "aws_iam_policy" "linux_users_get_secrets" {
  provider = aws.weform_data_source_provider
  arn      = "arn:aws:iam::${local.__weform_data_source_account_id}:policy/wt-${local.vpc_tags_prefix}-${local.aws_region_no_hyphens}-linux-users-get-secrets"
}