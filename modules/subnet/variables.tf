variable "resources" {
  description = "Map of subnet name → config"
  type        = map(any)
}

variable "vpc_ids" {
  description = "Map of VPC name → VPC ID (from vpc module output)"
  type        = map(string)
  default     = {}
}

variable "project" {
  type    = string
  default = "devops-ai"
}
