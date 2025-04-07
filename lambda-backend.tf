# Regra de acesso para a Lambda
resource "aws_iam_role" "ipecode_abnmo_lambda_exec_role" {
  name = "ipecode_abnmo_lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}
resource "aws_iam_role_policy_attachment" "ipecode_abnmo_lambda_basic_execution" {
  role       = aws_iam_role.ipecode_abnmo_lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Função lambda - versão main
resource "aws_lambda_function" "ipecode-abnmo-lambda-backend-main" {
  function_name = "ipecode-abnmo-lambda-backend-main"
  role          = aws_iam_role.ipecode_abnmo_lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = "placeholder.zip"
  source_code_hash = filebase64sha256("placeholder.zip")
  timeout       = 10
}

resource "aws_lambda_function_url" "lambda_url_main" {
  function_name      = aws_lambda_function.ipecode-abnmo-lambda-backend-main.function_name
  authorization_type = "NONE"

  cors {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["*"]
  }
}

# Função lambda - versão dev
resource "aws_lambda_function" "ipecode-abnmo-lambda-backend-dev" {
  function_name = "ipecode-abnmo-lambda-backend-dev"
  role          = aws_iam_role.ipecode_abnmo_lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = "placeholder.zip"
  source_code_hash = filebase64sha256("placeholder.zip")
  timeout       = 10
}

resource "aws_lambda_function_url" "lambda_url_dev" {
  function_name      = aws_lambda_function.ipecode-abnmo-lambda-backend-dev.function_name
  authorization_type = "NONE"

  cors {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["*"]
  }
}

# Função lambda - versão qa
resource "aws_lambda_function" "ipecode-abnmo-lambda-backend-qa" {
  function_name = "ipecode-abnmo-lambda-backend-qa"
  role          = aws_iam_role.ipecode_abnmo_lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = "placeholder.zip"
  source_code_hash = filebase64sha256("placeholder.zip")
  timeout       = 10
}

resource "aws_lambda_function_url" "lambda_url_qa" {
  function_name      = aws_lambda_function.ipecode-abnmo-lambda-backend-qa.function_name
  authorization_type = "NONE"

  cors {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["*"]
  }
}

output "lambda_url_main" {
  value = aws_lambda_function_url.lambda_url_main.function_url
}

output "lambda_url_dev" {
  value = aws_lambda_function_url.lambda_url_dev.function_url
}

output "lambda_url_qa" {
  value = aws_lambda_function_url.lambda_url_qa.function_url
}
