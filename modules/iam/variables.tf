variable "name" {
  description = "Prefixo dos nomes (gera <name>-role e <name>-policy)"
  type        = string
}

variable "assume_role_services" {
  description = "Servicos AWS que podem assumir a role"
  type        = list(string)
  default     = ["lambda.amazonaws.com"]
}

variable "policy_statements" {
  description = "Permissoes da role"
  type = list(object({
    sid       = optional(string)
    effect    = optional(string, "Allow")
    actions   = list(string)
    resources = list(string)
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
