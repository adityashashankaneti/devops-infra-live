data "archive_file" "placeholder" {
  for_each = var.resources

  type        = "zip"
  output_path = "${path.module}/.build/${each.key}.zip"

  source {
    content  = "# placeholder — deploy your code via CI/CD"
    filename = "index.py"
  }
}

resource "aws_iam_role" "lambda" {
  for_each = var.resources

  name = "${each.key}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = { Name = each.key, Project = var.project, ManagedBy = "terraform" }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  for_each = var.resources

  role       = aws_iam_role.lambda[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC access policy (when Lambda is placed in a VPC)
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  for_each = { for k, v in var.resources : k => v if try(v.subnet_names, null) != null }

  role       = aws_iam_role.lambda[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# ── Connection-based least-privilege IAM policies ────────────────────────────
# Each entry in iam_policies[] generates an inline policy on the Lambda role.
# Claude generates these from canvas connections (e.g. Lambda→DynamoDB, Lambda→S3).
locals {
  lambda_policies = flatten([
    for fn_key, fn in var.resources : [
      for idx, pol in try(fn.iam_policies, []) : {
        fn_key     = fn_key
        policy_key = "${fn_key}-${pol.sid}"
        sid        = pol.sid
        actions    = pol.actions
        resources  = pol.resources
      }
    ]
  ])
}

resource "aws_iam_role_policy" "lambda_connection" {
  for_each = { for p in local.lambda_policies : p.policy_key => p }

  name = each.value.sid
  role = aws_iam_role.lambda[each.value.fn_key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = each.value.sid
      Effect   = "Allow"
      Action   = each.value.actions
      Resource = each.value.resources
    }]
  })
}

# ── Invocation permissions from other AWS services ───────────────────────────
# Claude generates invoke_permissions[] when another service targets this Lambda
# (e.g. EventBridge → Lambda, SNS → Lambda, API Gateway → Lambda).
# Each entry: { source_service, source_arn (optional), statement_id }
locals {
  lambda_permissions = flatten([
    for fn_key, fn in var.resources : [
      for idx, perm in try(fn.invoke_permissions, []) : {
        perm_key       = "${fn_key}-${idx}"
        fn_key         = fn_key
        statement_id   = try(perm.statement_id, "allow-${idx}")
        source_service = perm.source_service
        source_arn     = try(perm.source_arn, null)
      }
    ]
  ])
}

resource "aws_lambda_permission" "this" {
  for_each = { for p in local.lambda_permissions : p.perm_key => p }

  statement_id  = each.value.statement_id
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this[each.value.fn_key].function_name
  principal     = each.value.source_service

  source_arn = each.value.source_arn
}

resource "aws_lambda_function" "this" {
  for_each = var.resources

  function_name = each.key
  role          = aws_iam_role.lambda[each.key].arn
  handler       = try(each.value.handler, "index.handler")
  runtime       = try(each.value.runtime, "python3.12")
  memory_size   = try(each.value.memory_size, 128)
  timeout       = try(each.value.timeout, 30)

  filename         = data.archive_file.placeholder[each.key].output_path
  source_code_hash = data.archive_file.placeholder[each.key].output_base64sha256

  dynamic "environment" {
    for_each = try(each.value.environment_variables, null) != null ? [1] : []
    content {
      variables = each.value.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = try(each.value.subnet_names, null) != null ? [1] : []
    content {
      subnet_ids         = [for s in each.value.subnet_names : lookup(var.subnet_ids, s, null)]
      security_group_ids = try([for sg in each.value.security_groups : var.security_group_ids[sg]], [])
    }
  }

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}
