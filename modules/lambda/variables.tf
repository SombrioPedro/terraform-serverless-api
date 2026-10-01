variable "function_name" {
  type = string
}

variable "source_dir" {
  description = "Pasta com o codigo da funcao"
  type        = string
}

variable "handler" {
  type = string
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "timeout" {
  type    = number
  default = 10
}

variable "role_arn" {
  type = string
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "log_retention_days" {
  type    = number
  default = 7
}

variable "layers" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
