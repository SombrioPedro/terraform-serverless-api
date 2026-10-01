output "api_url" {
  value = module.api_gateway.api_endpoint
}

output "dynamodb_table_name" {
  value = module.dynamodb.name
}

output "lambda_function_name" {
  value = module.lambda.function_name
}

output "lambda_arn" {
  value = module.lambda.arn
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
