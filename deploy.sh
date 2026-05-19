#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$ROOT_DIR/terraform"
ANSIBLE_DIR="$ROOT_DIR/ansible"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

usage() {
  cat <<'EOF'
Usage:
  ./deploy.sh deploy    Provision EC2, install Kubernetes, deploy sample app
  ./deploy.sh status    Show kubectl evidence from the control-plane node
  ./deploy.sh destroy   Destroy AWS infrastructure

Before deploy:
  cp terraform/terraform.tfvars.example terraform/terraform.tfvars
  edit terraform/terraform.tfvars
EOF
}

need() {
  command -v "$1" >/dev/null 2>&1 || error "$1 is not installed"
}

expand_path() {
  case "$1" in
    "~/"*) printf '%s/%s\n' "$HOME" "${1#"~/"}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

require_tfvars() {
  if [ ! -f "$TF_DIR/terraform.tfvars" ]; then
    error "terraform/terraform.tfvars not found. Copy terraform.tfvars.example and fill in your values."
  fi
}

check_prerequisites() {
  log "Checking prerequisites..."
  for cmd in terraform ansible-playbook aws ssh; do
    need "$cmd"
  done

  aws sts get-caller-identity >/dev/null 2>&1 || error "AWS credentials not configured. Run aws configure or export AWS credentials."
  require_tfvars
  log "All prerequisites met."
}

terraform_output() {
  terraform -chdir="$TF_DIR" output -raw "$1"
}

wait_for_ssh() {
  local host="$1"
  local ssh_user="$2"
  local key_path="$3"
  local attempt

  log "Waiting for SSH on $host..."
  for attempt in $(seq 1 30); do
    if ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 -i "$key_path" "$ssh_user@$host" true >/dev/null 2>&1; then
      log "SSH ready on $host"
      return 0
    fi

    warn "Attempt $attempt/30: still waiting for $host"
    sleep 10
  done

  error "Timeout waiting for SSH on $host"
}

provision_infra() {
  log "Provisioning infrastructure with Terraform..."
  terraform -chdir="$TF_DIR" init -input=false
  terraform -chdir="$TF_DIR" plan -out=tfplan
  terraform -chdir="$TF_DIR" apply -auto-approve tfplan
  rm -f "$TF_DIR/tfplan"
  log "Infrastructure provisioned."
}

wait_for_instances() {
  local ssh_user
  local key_path
  local inventory
  local host

  ssh_user="$(terraform_output ssh_user)"
  key_path="$(expand_path "$(terraform_output private_key_path)")"
  inventory="$ANSIBLE_DIR/inventory/hosts.ini"

  if [ ! -f "$inventory" ]; then
    error "Ansible inventory was not generated at $inventory"
  fi

  while read -r host; do
    wait_for_ssh "$host" "$ssh_user" "$key_path"
  done < <(sed -n 's/.*ansible_host=\([^ ]*\).*/\1/p' "$inventory")
}

configure_cluster() {
  log "Configuring Kubernetes cluster with Ansible..."
  ANSIBLE_CONFIG="$ANSIBLE_DIR/ansible.cfg" ansible-playbook "$ANSIBLE_DIR/main.yml"
  log "Cluster configured."
}

show_status() {
  need terraform
  need ssh
  require_tfvars

  local master_ip
  local ssh_user
  local key_path
  master_ip="$(terraform_output master_public_ip)"
  ssh_user="$(terraform_output ssh_user)"
  key_path="$(expand_path "$(terraform_output private_key_path)")"

  log "Fetching cluster status..."
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$key_path" "$ssh_user@$master_ip" '
    set -e
    kubectl get nodes -o wide
    echo
    kubectl get pods -o wide
    echo
    kubectl get deployments -o wide
    echo
    kubectl get services -o wide
  '

  echo
  log "Sample app URL: $(terraform_output sample_app_url)"
  log "SSH: $(terraform_output ssh_master)"
}

destroy_infra() {
  need terraform
  require_tfvars
  warn "Destroying all infrastructure..."
  terraform -chdir="$TF_DIR" destroy -auto-approve
  log "Infrastructure destroyed."
}

case "${1:-}" in
  deploy)
    check_prerequisites
    provision_infra
    wait_for_instances
    configure_cluster
    show_status
    ;;
  status)
    show_status
    ;;
  destroy)
    destroy_infra
    ;;
  -h | --help | help)
    usage
    ;;
  *)
    usage
    exit 1
    ;;
esac
