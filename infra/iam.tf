# resource "aws_iam_policy" "lambda_apigateway_policy" {
#   name        = "lambda-apigateway-policy"
#   description = "lambda_execution_policy"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#         "dynamodb:DeleteItem",
#         "dynamodb:GetItem",
#         "dynamodb:PutItem",
#         "dynamodb:Query",
#         "dynamodb:Scan",
#         "dynamodb:UpdateItem"
#       ],
#         Effect   = "Allow"
#         Resource = "*"
#       },
#         {
#         Action = [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#         Effect   = "Allow"
#         Resource = "*"
#       },
#     ]
#   })
# }

resource "aws_iam_policy" "lambda_apigateway_policy" {
  name        = "lambda-apigateway-policy"
  description = "lambda_execution_policy"
  policy = data.aws_iam_policy_document.lambda_execution_policy_document.json

}

data "aws_iam_policy_document" "lambda_execution_policy_document" {
  statement {
    actions = [
      "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:UpdateItem"
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
       "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "lambda_apigateway_role" {
  name = "lambda-apigateway-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

}

resource "aws_iam_role_policy_attachment" "lambda_apigateway_attachment" {
  role       = aws_iam_role.lambda_apigateway_role.name
  policy_arn = aws_iam_policy.lambda_apigateway_policy.arn
}