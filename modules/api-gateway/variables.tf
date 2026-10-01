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

variable "tags" {
  type    = map(string)
  default = {}
}
