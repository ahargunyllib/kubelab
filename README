# Kubelab: LK Kubernetes

Repo ini adalah versi otomatis dari LK Kubernetes. Terraform membuat 1 master dan 1 worker EC2 di AWS, lalu Ansible mengubah alur `techiescamp/kubeadm-scripts` menjadi playbook idempotent untuk install Kubernetes, join worker, dan deploy sample Nginx.

Target versi mengikuti upstream `kubeadm-scripts`:

- Kubernetes `v1.36`
- CRI-O `v1.36`
- crictl `v1.36.0`
- Calico `v3.32.0`

## Prerequisites

- Nix atau tool manual berikut:
  - Terraform >= 1.5
  - Ansible >= 2.15
  - AWS CLI
  - SSH
- AWS credentials sudah aktif.
- AWS EC2 key pair sudah dibuat.

## Quick Start

Masuk dev shell:

```bash
nix develop
```

Buat key pair jika belum ada:

```bash
aws ec2 create-key-pair --key-name kubelab --query 'KeyMaterial' --output text > ~/.ssh/kubelab.pem
chmod 400 ~/.ssh/kubelab.pem
```

Copy dan edit konfigurasi Terraform:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Contoh isi penting:

```hcl
key_name         = "kubelab"
private_key_path = "~/.ssh/kubelab.pem"

# Lebih aman: ganti dengan IP publik kamu dalam format CIDR.
# allowed_cidr = "203.0.113.10/32"
allowed_cidr = "0.0.0.0/0"
```

Deploy:

```bash
./deploy.sh deploy
```

Cek bukti untuk screenshot:

```bash
./deploy.sh status
```

Cleanup setelah selesai:

```bash
./deploy.sh destroy
```

## Yang Dibuat

- 1 EC2 control-plane.
- 1 EC2 worker.
- VPC, subnet publik, internet gateway, route table.
- Security group untuk SSH, Kubernetes API, dan NodePort.
- Inventory Ansible otomatis di `ansible/inventory/hosts.ini`.
- Vars Ansible otomatis di `ansible/vars/infra.yml`.
- Kubernetes via kubeadm + CRI-O + Calico.
- Sample app Nginx dengan NodePort `32000` lewat worker public IP.

## Struktur

```text
kubelab/
├── deploy.sh
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── templates/
│       ├── inventory.tftpl
│       └── infra.yml.tftpl
├── ansible/
│   ├── ansible.cfg
│   ├── main.yml
│   ├── inventory/
│   ├── vars/
│   └── playbooks/
│       ├── 00-common-setup.yml
│       ├── 01-control-plane.yml
│       ├── 02-worker-join.yml
│       ├── 03-sample-app.yml
│       └── 04-show-evidence.yml
├── k8s/
│   └── sample-app.yaml
└── flake.nix
```

## Mapping ke kubeadm-scripts

- `00-common-setup.yml`: konversi `scripts/common.sh`.
- `01-control-plane.yml`: konversi `scripts/control-plane.sh`.
- `02-worker-join.yml`: konversi `kubeadm-full-set/scripts/node.sh`.
- `03-sample-app.yml`: deploy manifest dari `manifests/sample-app.yaml`.
- `04-show-evidence.yml`: menampilkan output yang bisa dipakai untuk screenshot LK.
