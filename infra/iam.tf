# ----------- Lambda Role & Policy -----------
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
      "arn:aws:dynamodb:eu-west-1:908027392248:table/lambda-apigateway"
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_apigateway_policy" {
  name        = "lambda-apigateway-policy"
  description = "lambda_execution_policy"
  policy      = data.aws_iam_policy_document.lambda_execution_policy_document.json
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
  name               = "lambda-apigateway-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_apigateway_attachment" {
  role       = aws_iam_role.lambda_apigateway_role.name
  policy_arn = aws_iam_policy.lambda_apigateway_policy.arn
}

# ----------- GitHub Actions Role Policy -----------
data "aws_iam_policy_document" "github_actions_dynamodb_backend_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]
    resources = [
      "arn:aws:dynamodb:eu-west-1:908027392248:table/terraform-backend-TerraformBackendDynamoDBTable-1MWDTO5LZO1U9"
    ]
  }
}

resource "aws_iam_policy" "github_actions_dynamodb_backend_policy" {
  name        = "github-actions-dynamodb-backend-policy"
  description = "Allow GitHub Actions to access DynamoDB backend used by Terraform"
  policy      = data.aws_iam_policy_document.github_actions_dynamodb_backend_policy.json
}

data "aws_iam_role" "github_actions_role" {
  name = "deploy-terraform"
}

resource "aws_iam_role_policy_attachment" "github_actions_backend_policy_attachment" {
  role       = data.aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_dynamodb_backend_policy.arn
}


data "aws_iam_policy_document" "github_actions_extra_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "apigateway:GET",
      "dynamodb:DescribeTable",
      "lambda:GetFunction"
    ]
    resources = ["*"] # tu peux restreindre ça à des ARNs précis plus tard si besoin
  }
}

resource "aws_iam_policy" "github_actions_extra_permissions_policy" {
  name        = "github-actions-extra-permissions"
  description = "Allow GitHub Actions to access API Gateway, Lambda and DynamoDB read access"
  policy      = data.aws_iam_policy_document.github_actions_extra_permissions.json
}

resource "aws_iam_role_policy_attachment" "github_actions_extra_permissions_attachment" {
  role       = data.aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_extra_permissions_policy.arn
}
