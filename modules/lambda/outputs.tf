output "function_arns" {
  value = { for k, v in aws_lambda_function.this : k => v.arn }
}

output "function_names" {
  value = { for k, v in aws_lambda_function.this : k => v.function_name }
}

output "invoke_arns" {
  value = { for k, v in aws_lambda_function.this : k => v.invoke_arn }
}

output "role_arns" {
  value = { for k, v in aws_iam_role.lambda : k => v.arn }
}
