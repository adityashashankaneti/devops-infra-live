variable "resources" {
  type = map(any)
}

variable "subnet_ids" {
  type    = map(string)
  default = {}
}

variable "project" {
  type    = string
  default = "devops-ai"
}
