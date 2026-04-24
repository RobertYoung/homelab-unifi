# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Single-host Ansible project deploying UniFi OS Server on `unifi.local.iamrobertyoung.co.uk`. Secrets are stored in AWS SSM Parameter Store.

## Key Commands

All commands require AWS credentials via aws-vault for SSM parameter lookups.

```bash
# Test connectivity
aws-vault exec iamrobertyoung:home-assistant-production:p -- ansible unifi -m ping

# Run full playbook
aws-vault exec iamrobertyoung:home-assistant-production:p -- ansible-playbook playbooks/site.yml

# Run specific role only
aws-vault exec iamrobertyoung:home-assistant-production:p -- ansible-playbook playbooks/site.yml --tags unifi-os-server

# Install external dependencies (roles)
aws-vault exec iamrobertyoung:home-assistant-production:p -- ansible-galaxy install -r requirements.yml -p .roles

# Lint
yamllint .
ansible-lint
```

## Architecture

### Deployment Stack
The main playbook (`playbooks/site.yml`) applies these roles in order:
1. `configure-system` - Base system configuration
2. `shell` - Shell setup for users (noxious, root)
3. `podman` - Podman installation
4. `step-ca-client` - TLS certificates from Step CA
5. `telegraf` - Metrics collection to InfluxDB
6. `syslog` - Syslog configuration
7. `wazuh-agent` - Security monitoring agent
8. `unifi-os-server` - UniFi OS Server deployment with Traefik reverse proxy and S3 backup systemd timer

### UniFi OS Server Role Structure
The `roles/unifi-os-server` role deploys UniFi OS Server alongside a Traefik reverse proxy and a backup-toolkit container run on a systemd timer:
- `tasks/main.yml` - Orchestrates install, setup, traefik, backup
- `defaults/main.yml` - Default variables (prefix: `uosserver_`)
- `templates/quadlet/` - Podman Quadlet units (traefik, backup-toolkit)
- `templates/traefik/` - Traefik static + dynamic config
- `templates/backup/` - Backup systemd service and timer templates
- `files/Dockerfile` + `files/backup.sh` - Locally-built backup-toolkit image (awscli + mosquitto-clients) that uploads the newest `.unf` to S3 and publishes a timestamp to MQTT

Key directories on target host:
- `/etc/unifi/` - Role config (certs, env files)
- `/etc/containers/systemd/` - Podman Quadlet units

### Secrets Management
Secrets are stored in AWS SSM Parameter Store (region: eu-west-1) under `/homelab/*`.
Ansible retrieves them via `lookup('aws_ssm', '/homelab/path/to/secret', region='eu-west-1')`.

### External Dependencies
Dependencies in `requirements.yml` are installed to `.roles/` (gitignored). External roles use SSH git URLs requiring SSH keys.

### Available Tags
Run specific parts with `--tags`: `configure-system`, `shell`, `podman`, `step-ca-client`, `telegraf`, `syslog`, `wazuh-agent`, `unifi-os-server`

### Tool Versions (mise.toml)
- ansible 13.1.0
- pipx 1.8.0
- uv 0.9.18
