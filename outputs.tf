output "dynamodb_table_name" {
  value = aws_dynamodb_table.products.name
}

output "lambda_function_name" {
  value = aws_lambda_function.products.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.products.arn
}

output "api_url" {
  description = "URL base da API"
  value       = aws_apigatewayv2_api.api.api_endpoint
}