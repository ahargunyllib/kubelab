variable "project_name" {
  description = "Name prefix for AWS resources."
  type        = string
  default     = "kubelab"
}

variable "aws_region" {
  description = "AWS region for this lab."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC."
  type        = string
  default     = "10.30.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.30.1.0/24"
}

variable "allowed_cidr" {
  description = "CIDR allowed to access SSH, Kubernetes API, and NodePort services."
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name."
  type        = string
}

variable "private_key_path" {
  description = "Local private key path used by SSH and Ansible."
  type        = string
}

variable "ssh_user" {
  description = "SSH user for Ubuntu EC2 instances."
  type        = string
  default     = "ubuntu"
}

variable "master_instance_type" {
  description = "EC2 instance type for the control-plane node."
  type        = string
  default     = "t3.large"
}

variable "worker_instance_type" {
  description = "EC2 instance type for worker nodes."
  type        = string
  default     = "t3.large"
}

variable "worker_count" {
  description = "Number of Kubernetes worker nodes."
  type        = number
  default     = 1
}

variable "root_volume_size" {
  description = "Root disk size in GiB."
  type        = number
  default     = 40
}

variable "kubernetes_version" {
  description = "Kubernetes repository version."
  type        = string
  default     = "v1.36"
}

variable "crio_version" {
  description = "CRI-O repository version."
  type        = string
  default     = "v1.36"
}

variable "crictl_version" {
  description = "crictl release version."
  type        = string
  default     = "v1.36.0"
}

variable "kubernetes_install_version" {
  description = "Exact kubeadm/kubelet/kubectl apt package version."
  type        = string
  default     = "1.36.0-1.1"
}

variable "calico_version" {
  description = "Calico release version."
  type        = string
  default     = "v3.32.0"
}

variable "pod_network_cidr" {
  description = "Pod network CIDR used by kubeadm and Calico."
  type        = string
  default     = "192.168.0.0/16"
}

variable "sample_app_nodeport" {
  description = "NodePort for the sample Nginx app."
  type        = number
  default     = 32000
}

variable "tags" {
  description = "Extra tags applied to AWS resources."
  type        = map(string)
  default     = {}
}
