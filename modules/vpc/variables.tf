variable "resources" {
  description = "Map of VPC name → config"
  type        = map(any)
}

variable "project" {
  description = "Project name for tagging"
  type        = string
  default     = "devops-ai"
}
