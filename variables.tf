variable "token" {
  type = string
  description = "Your Linode API Personal Access Token. (required)"
}

variable "root_password" {
  type = string
  description = "Password for Leader node (Required)"
}

variable "linode_image" {
  type = string
  description = "Linode Image to be used"
  default = "linode/ubuntu23.10"
}

variable "linode_plan_type" {
  type = string
  description = "Linode plan to be used"
  default = "g6-nanode-1"
}

variable "locust_tags" {
  type = list(string)
  description = "Tags for the Locust deployment"
  default = ["locust"]
}

variable "leader_region" {
  type = string
  description = "Region for the leader node"
  default = "us-mia"
}

variable "node_regions" {
  type = list(string)
  description = "Regions for the leader nodes"
  default = ["us-lax"]
}

variable "locust_plan_filename" {
  type = string
  description = "Locust plan filename"
  default = "locustfile.py"
}

variable "locust_version" {
  type = string
  description = "Locust version"
  default = "2.18.3"
}

variable "uses_mtls" {
  type = bool
  description = "Indicates whether mTLS certs are required"
  default = false
}

variable "server_cert" {
  type = string
  description = "Server certificate"
  default = "server_cert.crt"
}

variable "client_cert" {
  type = string
  description = "Client certificate"
  default = "client_cert.pem"
}

variable "client_key" {
  type = string
  description = "Client key"
  default = "client_key.pkey"
}