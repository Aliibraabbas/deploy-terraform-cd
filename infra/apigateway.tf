resource "aws_api_gateway_rest_api" "dynamo_db_operations" {
  name = "TodoList"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

resource "aws_api_gateway_resource" "dynamodb_manager" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  parent_id   = aws_api_gateway_rest_api.dynamo_db_operations.root_resource_id
  path_part   = "todos"
}

# POST METHOD
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id   = aws_api_gateway_resource.dynamodb_manager.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_method" {
  rest_api_id             = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id             = aws_api_gateway_resource.dynamodb_manager.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function_over_https.invoke_arn
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.dynamodb_manager.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "post_method" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.dynamodb_manager.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  depends_on = [
    aws_api_gateway_integration.post_method
  ]
}

# OPTIONS METHOD for CORS
resource "aws_api_gateway_method" "option_method" {
  rest_api_id   = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id   = aws_api_gateway_resource.dynamodb_manager.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_method" {
  rest_api_id             = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id             = aws_api_gateway_resource.dynamodb_manager.id
  http_method             = aws_api_gateway_method.option_method.http_method
  type                    = "MOCK"
  integration_http_method = "POST"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.dynamodb_manager.id
  http_method = aws_api_gateway_method.option_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id
  resource_id = aws_api_gateway_resource.dynamodb_manager.id
  http_method = aws_api_gateway_method.option_method.http_method
  status_code = aws_api_gateway_method_response.options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_over_https.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.dynamo_db_operations.execution_arn}/*/*"
}

# Deployment
resource "aws_api_gateway_deployment" "dynamodb_manager" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_db_operations.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.dynamodb_manager.id,
      aws_api_gateway_method.post_method.id,
      aws_api_gateway_integration.post_method.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.post_method,
    aws_api_gateway_integration.options_method
  ]
}

resource "aws_api_gateway_stage" "dynamodb_manager" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.dynamo_db_operations.id
  deployment_id = aws_api_gateway_deployment.dynamodb_manager.id
}
