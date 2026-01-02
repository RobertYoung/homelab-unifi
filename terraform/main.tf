locals {
  tags = {
    Project   = "homelab-unifi"
    ManagedBy = "terraform"
    Source    = "https://github.com/RobertYoung/homelab-unifi"
  }
}

resource "aws_ssm_parameter" "mongodb_root_password_ireland" {
  name        = "/homelab/unifi/mongodb-root-password"
  description = "MongoDb root password"
  type        = "SecureString"
  value       = "CHANGE_ME"

  tags = local.tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "mongodb_unifi_password_ireland" {
  name        = "/homelab/unifi/mongodb-unifi-password"
  description = "MongoDb unifi password"
  type        = "SecureString"
  value       = "CHANGE_ME"

  tags = local.tags

  lifecycle {
    ignore_changes = [value]
  }
}
