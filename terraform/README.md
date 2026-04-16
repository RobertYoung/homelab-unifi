# UniFi Terraform Configuration

Manages the AWS SSM Parameter Store entries consumed by the `unifi` Ansible role.

## What This Creates

Two `SecureString` parameters in SSM (region `eu-west-1`):

- `/homelab/unifi/mongodb-root-password` — MongoDB root password
- `/homelab/unifi/mongodb-unifi-password` — MongoDB `unifi` app user password

Both resources use `lifecycle { ignore_changes = [value] }`, so Terraform creates the parameters with a `CHANGE_ME` placeholder on first apply and then leaves the value alone. Set the real values out-of-band (see [Setting values](#setting-values)).

State is stored in S3: `s3://terraform-iamrobertyoung/projects/homelab-unifi/main/tfstate.json` (`eu-west-1`).

## Prerequisites

- Terraform >= 1.14.0
- aws-vault with profile `iamrobertyoung:home-assistant-production:p`

## Usage

```bash
cd terraform
aws-vault exec iamrobertyoung:home-assistant-production:p -- terraform init
aws-vault exec iamrobertyoung:home-assistant-production:p -- terraform plan
aws-vault exec iamrobertyoung:home-assistant-production:p -- terraform apply
```

## Setting values

After `terraform apply` has created the parameters, set the real secrets directly in SSM. Terraform will not overwrite them on subsequent applies.

```bash
aws-vault exec iamrobertyoung:home-assistant-production:p -- \
  aws ssm put-parameter --region eu-west-1 --overwrite \
  --name /homelab/unifi/mongodb-root-password \
  --type SecureString --value '<root-password>'

aws-vault exec iamrobertyoung:home-assistant-production:p -- \
  aws ssm put-parameter --region eu-west-1 --overwrite \
  --name /homelab/unifi/mongodb-unifi-password \
  --type SecureString --value '<unifi-password>'
```

## Consumption by Ansible

`playbooks/site.yml` reads the parameters via:

```yaml
unifi_mongodb_root_password: "{{ lookup('aws_ssm', '/homelab/unifi/mongodb-root-password', region='eu-west-1') }}"
unifi_mongodb_password: "{{ lookup('aws_ssm', '/homelab/unifi/mongodb-unifi-password', region='eu-west-1') }}"
```

## Files

- `terraform.tf` — S3 backend config
- `versions.tf` — Provider versions and region
- `main.tf` — SSM parameter resources
