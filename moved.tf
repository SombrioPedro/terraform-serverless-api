moved {
  from = aws_dynamodb_table.products
  to   = module.dynamodb.aws_dynamodb_table.this
}

moved {
  from = aws_iam_role.lambda
  to   = module.iam.aws_iam_role.this
}

moved {
  from = aws_iam_policy.lambda
  to   = module.iam.aws_iam_policy.this
}

moved {
  from = aws_iam_role_policy_attachment.lambda
  to   = module.iam.aws_iam_role_policy_attachment.this
}

moved {
  from = aws_cloudwatch_log_group.lambda
  to   = module.lambda.aws_cloudwatch_log_group.this
}

moved {
  from = aws_lambda_function.products
  to   = module.lambda.aws_lambda_function.this
}

moved {
  from = aws_apigatewayv2_api.api
  to   = module.api_gateway.aws_apigatewayv2_api.this
}

moved {
  from = aws_apigatewayv2_integration.lambda
  to   = module.api_gateway.aws_apigatewayv2_integration.this
}

moved {
  from = aws_apigatewayv2_route.products
  to   = module.api_gateway.aws_apigatewayv2_route.this
}

moved {
  from = aws_apigatewayv2_stage.default
  to   = module.api_gateway.aws_apigatewayv2_stage.this
}

moved {
  from = aws_lambda_permission.apigw
  to   = module.api_gateway.aws_lambda_permission.this
}
