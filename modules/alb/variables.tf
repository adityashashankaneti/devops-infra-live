variable "resources" {
  type = map(any)
}

variable "subnet_ids" {
  type    = map(string)
  default = {}
}

variable "security_group_ids" {
  type    = map(string)
  default = {}
}

variable "vpc_ids" {
  type    = map(string)
  default = {}
}

variable "project" {
  type    = string
  default = "devops-ai"
}
