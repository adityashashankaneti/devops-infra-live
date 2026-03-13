variable "resources" {
  description = "Map of route table name → config"
  type        = map(any)
}

variable "vpc_ids" {
  description = "Map of VPC name → VPC ID"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "Map of subnet name → subnet ID"
  type        = map(string)
  default     = {}
}

variable "igw_ids" {
  description = "Map of IGW name → IGW ID"
  type        = map(string)
  default     = {}
}

variable "nat_gateway_ids" {
  description = "Map of NAT GW name → NAT Gateway ID"
  type        = map(string)
  default     = {}
}

variable "project" {
  type    = string
  default = "devops-ai"
}
