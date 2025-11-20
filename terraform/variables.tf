variable "join_master_count" {
  description = "Anzahl der Join Master Nodes"
  type        = number
  default     = 2
}

variable "join_worker_count" {
  description = "Anzahl der Join Worker Nodes"
  type        = number
  default     = 3
}

variable "volume_size" {
  description = "Root Volume size of nodes"
  type        = number
  default     = 20
}

variable "instance_type" {
  description = "AWS-Instance typen"
  type        = string
  default     = "t3.small"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "publickeyfile" {
  description = "File for Publickey"
  type        = string
  default     = "/tmp/mykey.pub"
}

variable "cidr_block" {
  description = "CIDR Block für die VPC"
  type        = string
  default     = "10.23.0.0/16"
}

