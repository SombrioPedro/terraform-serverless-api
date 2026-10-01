variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment deve ser dev, staging ou prod."
  }
}

variable "owner" {
  description = "Seu nome, usado como prefixo para identificar os recursos"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,15}$", var.owner))
    error_message = "Use só letras minúsculas, números e hífen (2 a 15 caracteres), sem acento nem espaço."
  }
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "products-api"
}

variable "lambda_runtime" {
  description = "Runtime da Lambda"
  type        = string
  default     = "python3.12"
}

variable "lambda_memory" {
  description = "Memória da Lambda em MB"
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Timeout da Lambda em segundos"
  type        = number
  default     = 10
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs no CloudWatch"
  type        = number
  default     = 7
}

variable "common_tags" {
  description = "Tags aplicadas aos recursos"
  type        = map(string)

  default = {
    ManagedBy = "terraform"
    Project   = "products-api"
    Owner     = "devops"
  }
}

variable "cors_allowed_origins" {
  description = "Origens autorizadas a chamar a API pelo navegador"
  type        = list(string)
  default     = ["*"]
}