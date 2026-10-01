locals {
  name_prefix = "${var.owner}-${var.project_name}-${var.environment}"
  tags = merge(var.common_tags, {
    Environment = var.environment
    Owner       = var.owner
  })

  api_routes = [
    "POST /products",
    "GET /products",
    "GET /products/{id}",
    "DELETE /products/{id}",
  ]
}

resource "terraform_data" "workspace_guard" {
  lifecycle {
    precondition {
      condition     = var.environment == terraform.workspace
      error_message = "O workspace atual (${terraform.workspace}) e diferente de environment (${var.environment}). Rode: terraform workspace select ${var.environment}"
    }
  }
}

module "dynamodb" {
  source = "./modules/dynamodb"

  name     = "${local.name_prefix}-products"
  hash_key = "id"
  tags     = local.tags
}

module "iam" {
  source = "./modules/iam"

  name = "${local.name_prefix}-lambda"
  policy_statements = [
    {
      sid       = "CloudWatchLogs"
      actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      resources = ["${module.lambda.log_group_arn}:*"]
    },
    {
      sid       = "DynamoDBProducts"
      actions   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:Scan", "dynamodb:DeleteItem"]
      resources = [module.dynamodb.arn]
    },
  ]
  tags = local.tags
}

module "lambda" {
  source = "./modules/lambda"

  function_name      = local.name_prefix
  source_dir         = "${path.module}/lambda"
  handler            = "lambda_function.lambda_handler"
  runtime            = var.lambda_runtime
  memory_size        = var.lambda_memory
  timeout            = var.lambda_timeout
  role_arn           = module.iam.role_arn
  log_retention_days = var.log_retention_days

  environment_variables = {
    TABLE_NAME = module.dynamodb.name
    LOG_LEVEL  = "INFO"
  }

  tags = local.tags
}

module "api_gateway" {
  source = "./modules/api-gateway"

  name                 = "${local.name_prefix}-api"
  lambda_function_name = module.lambda.function_name
  lambda_invoke_arn    = module.lambda.invoke_arn
  routes               = local.api_routes

  cors_allow_origins = var.cors_allowed_origins
  cors_allow_methods = ["GET", "POST", "DELETE", "OPTIONS"]
  cors_allow_headers = ["content-type", "x-api-key"]

  tags = local.tags
}
