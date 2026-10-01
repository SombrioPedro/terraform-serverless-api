output "role_arn" {
  value      = aws_iam_role.this.arn
  depends_on = [aws_iam_role_policy_attachment.this]
}

output "role_name" {
  value = aws_iam_role.this.name
}

output "policy_arn" {
  value = aws_iam_policy.this.arn
}
