# Quem pode "assumir" a role: o serviço Lambda
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# O que a Lambda pode fazer (least privilege)
data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    sid = "CloudWatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.lambda.arn}:*"]
  }

  statement {
    sid = "DynamoDBProducts"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:DeleteItem",
    ]
    resources = [aws_dynamodb_table.products.arn]
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/build/lambda.zip"
}