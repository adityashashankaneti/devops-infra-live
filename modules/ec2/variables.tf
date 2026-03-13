variable "resources" {
  description = "Map of instance name → config"
  type        = map(any)
}

variable "subnet_ids" {
  description = "Map of subnet name → subnet ID"
  type        = map(string)
  default     = {}
}

variable "security_group_ids" {
  description = "Map of SG name → SG ID"
  type        = map(string)
  default     = {}
}

variable "project" {
  type    = string
  default = "devops-ai"
}
