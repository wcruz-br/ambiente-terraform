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
  function_name    = "ipecode-abnmo-lambda-backend-main"
  role             = aws_iam_role.ipecode_abnmo_lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = "placeholder.zip"
  source_code_hash = filebase64sha256("placeholder.zip")
  timeout          = 10
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
  function_name    = "ipecode-abnmo-lambda-backend-dev"
  role             = aws_iam_role.ipecode_abnmo_lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = "placeholder.zip"
  source_code_hash = filebase64sha256("placeholder.zip")
  timeout          = 10

  environment {
    variables = {

      NODE_ENV        = "development"

      APP_URL         = "https://dev--abnmo.netlify.app"
      APP_ENVIRONMENT = "development"

      COOKIE_DOMAIN   = "abnmo.netlify.app"
      COOKIE_SECRET   = "d0f8a994-46d5-82a0-bad7-e9464cbe1845"
      JWT_SECRET      = "$2a$12$H8AX84XU9UaUAtkttFrkn.1L/.3OpGS4sALMqttWriljWiJL/N51O"

      DB_HOST         = "abnmo-db-dev.ipecode.com.br"
      DB_PORT         = "3306"
      DB_DATABASE     = "abnmo_dev"
      DB_USERNAME     = "abnmo_dev"
      DB_PASSWORD     = file("${path.module}/secrets/abnmo_dev_pwd.txt")

    }
  }

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
  function_name    = "ipecode-abnmo-lambda-backend-qa"
  role             = aws_iam_role.ipecode_abnmo_lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = "placeholder.zip"
  source_code_hash = filebase64sha256("placeholder.zip")
  timeout          = 10

  environment {
    variables = {

      NODE_ENV        = "test"

      APP_URL         = "https://homolog--abnmo.netlify.app"
      APP_ENVIRONMENT = "homolog"

      COOKIE_DOMAIN   = "abnmo.netlify.app"
      COOKIE_SECRET   = "d0f8a994-bad7-46d5-82a0-e9464cbe1845"
      JWT_SECRET      = "$2a$12$YfjA.G05PJf5EpGjdKFpbOUvrrSG6Mm7Zp6l2YN2/25LbDGdB/m/a"

      DB_HOST         = "abnmo-db-qa.ipecode.com.br"
      DB_PORT         = "3306"
      DB_DATABASE     = "abnmo_qa"
      DB_USERNAME     = "abnmo_qa"
      DB_PASSWORD     = file("${path.module}/secrets/abnmo_qa_pwd.txt")

    }
  }
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

# Configuração do OIDC para o GitHub Actions
# Essa configuração permite que o GitHub Actions faça deploy na Lambda
# usando o OIDC (OpenID Connect) para autenticação
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1" # Thumbprint oficial do GitHub OIDC
  ]
}

# Role para o GitHub Actions fazer deploy na Lambda
resource "aws_iam_role" "github_oidc_lambda_deploy" {
  name = "github-actions-lambda-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        },
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:ipecode-br/abnmo-backend:ref:refs/heads/*",
            "repo:ipecode-br/abnmo-backend:environment:production",
            "repo:ipecode-br/abnmo-backend:environment:development",
            "repo:ipecode-br/abnmo-backend:environment:homolog",
          ]
        }
      }
    }]
  })
}
resource "aws_iam_policy" "lambda_deploy_policy" {
  name        = "lambda-deploy-permissions"
  description = "Permite GitHub atualizar funções Lambda via OIDC"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:GetFunctionConfiguration",
          "lambda:UpdateFunctionConfiguration"
        ],
        Resource = [
          aws_lambda_function.ipecode-abnmo-lambda-backend-main.arn,
          aws_lambda_function.ipecode-abnmo-lambda-backend-dev.arn,
          aws_lambda_function.ipecode-abnmo-lambda-backend-qa.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_deploy_policy" {
  role       = aws_iam_role.github_oidc_lambda_deploy.name
  policy_arn = aws_iam_policy.lambda_deploy_policy.arn
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

output "github_oidc_deploy_role_arn" {
  value = aws_iam_role.github_oidc_lambda_deploy.arn
}
