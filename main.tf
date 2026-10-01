locals {
  name_prefix = "${var.owner}-${var.project_name}-${var.environment}"
  tags = merge(var.common_tags, {
    Environment = var.environment
    Owner       = var.owner
  })

  # Mesmas rotas do dicionário ROUTES no Python
  api_routes = [
    "POST /products",
    "GET /products",
    "GET /products/{id}",
    "DELETE /products/{id}",
  ]
}
# ---------- DynamoDB ----------
resource "aws_dynamodb_table" "products" {
  name         = "${local.name_prefix}-products"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  lifecycle {
    precondition {
      condition     = var.environment == terraform.workspace
      error_message = "O workspace atual (${terraform.workspace}) é diferente de environment (${var.environment}). Rode: terraform workspace select ${var.environment}"
    }
  }

  tags = local.tags
}

# ---------- CloudWatch ----------
# O nome precisa ser /aws/lambda/<nome-da-funcao>
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.name_prefix}"
  retention_in_days = var.log_retention_days
  tags              = local.tags
}

# ---------- IAM ----------
resource "aws_iam_role" "lambda" {
  name               = "${local.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_policy" "lambda" {
  name   = "${local.name_prefix}-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_permissions.json
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

# ---------- Lambda ----------
resource "aws_lambda_function" "products" {
  function_name = local.name_prefix
  role          = aws_iam_role.lambda.arn
  runtime       = var.lambda_runtime
  handler       = "lambda_function.lambda_handler"
  memory_size   = var.lambda_memory
  timeout       = var.lambda_timeout

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.products.name
      LOG_LEVEL  = "INFO"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda,
  ]

  tags = local.tags
}

# ---------- API Gateway ----------
resource "aws_apigatewayv2_api" "api" {
  name          = "${local.name_prefix}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.cors_allowed_origins
    allow_methods = ["GET", "POST", "DELETE", "OPTIONS"]
    allow_headers = ["content-type", "x-api-key"]
    max_age       = 300
  }

  tags = local.tags
}

# Liga a API à Lambda (proxy: repassa a requisição inteira)
resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.products.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Uma rota para cada endpoint, todas apontando para a mesma integração
resource "aws_apigatewayv2_route" "products" {
  for_each = toset(local.api_routes)

  api_id    = aws_apigatewayv2_api.api.id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Stage $default com auto_deploy: a URL fica sem /dev, /prod etc.
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
  tags        = local.tags
}

# ---------- Lambda Permission ----------
# Autoriza o API Gateway (e só esta API) a invocar a Lambda
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.products.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}