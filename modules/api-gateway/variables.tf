variable "name" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "lambda_invoke_arn" {
  type = string
}

variable "routes" {
  description = "Rotas no formato METODO /caminho"
  type        = list(string)

  validation {
    condition     = length(var.routes) > 0
    error_message = "Informe pelo menos uma rota."
  }
}

variable "cors_allow_origins" {
  description = "Lista vazia desativa o CORS"
  type        = list(string)
  default     = []
}

variable "cors_allow_methods" {
  type    = list(string)
  default = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
}

variable "cors_allow_headers" {
  type    = list(string)
  default = ["content-type"]
}

variable "cors_max_age" {
  type    = number
  default = 300
}

variable "enable_authorizer" {
  description = "Ativa a Lambda authorizer em todas as rotas"
  type        = bool
  default     = false
}

variable "authorizer_lambda_invoke_arn" {
  description = "invoke_arn da Lambda authorizer"
  type        = string
  default     = null
}

variable "authorizer_lambda_function_name" {
  description = "Nome da Lambda authorizer"
  type        = string
  default     = null
}

variable "authorizer_identity_header" {
  description = "Header que o authorizer confere"
  type        = string
  default     = "x-api-key"
}

variable "authorizer_cache_ttl" {
  description = "Segundos que o resultado da autorizacao fica em cache"
  type        = number
  default     = 300
}

variable "tags" {
  type    = map(string)
  default = {}
}
