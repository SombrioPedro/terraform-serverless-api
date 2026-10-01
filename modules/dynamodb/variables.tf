variable "name" {
  description = "Nome da tabela"
  type        = string
}

variable "hash_key" {
  description = "Nome da partition key"
  type        = string
  default     = "id"
}

variable "hash_key_type" {
  description = "Tipo da partition key: S, N ou B"
  type        = string
  default     = "S"
}

variable "range_key" {
  description = "Nome da sort key (opcional)"
  type        = string
  default     = null
}

variable "range_key_type" {
  description = "Tipo da sort key"
  type        = string
  default     = "S"
}

variable "billing_mode" {
  description = "PAY_PER_REQUEST ou PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "tags" {
  type    = map(string)
  default = {}
}
