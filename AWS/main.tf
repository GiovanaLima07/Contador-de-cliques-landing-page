# --- 1. CONFIGURAÇÃO DO PROVIDER ---
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# --- 2. VARIÁVEIS ---
variable "project_name" {
  type        = string
  default     = "contador-cliques"
  description = "Prefixo para identificar os recursos do projeto"
}

variable "allowed_origins" {
  type        = list(string)
  default     = ["*"]
  description = "Origens autorizadas no CORS da API. Em produção, troque o * pelos endereços do site."
}

# --- 3. DYNAMODB ---
resource "aws_dynamodb_table" "cliques" {
  name         = "cliques-produtos"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "produto"
  range_key    = "periodo"

  attribute {
    name = "produto"
    type = "S"
  }

  attribute {
    name = "periodo"
    type = "S"
  }

  tags = {
    Project = var.project_name
  }
}

# --- 4. IAM PARA A LAMBDA ---
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "${var.project_name}-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:UpdateItem", "dynamodb:Scan"]
        Resource = aws_dynamodb_table.cliques.arn
      }
    ]
  })
}

# --- 5. LAMBDA ---
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_payload.zip"
}

# Grupo de logs criado antes da Lambda, com retenção de 7 dias
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/registrar-clique"
  retention_in_days = 7
}

resource "aws_lambda_function" "registrar_clique" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "registrar-clique"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABELA = aws_dynamodb_table.cliques.name # o código lê a variável TABELA
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}

# --- 6. API GATEWAY (HTTP API) ---
resource "aws_apigatewayv2_api" "api" {
  name          = "api-cliques"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.allowed_origins
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.registrar_clique.invoke_arn
  integration_method = "POST"

  payload_format_version = "2.0" # o código da Lambda lê routeKey, que só existe neste formato
}

resource "aws_apigatewayv2_route" "post_clique" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /clique/{produto}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "get_cliques" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /cliques"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.registrar_clique.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

# --- 7. OUTPUTS ---
output "api_url" {
  value       = aws_apigatewayv2_api.api.api_endpoint
  description = "URL da API Gateway para configurar no front-end"
}