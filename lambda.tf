# Zip the lambda code
data "archive_file" "init" {
  type        = "zip"
  source_dir  = "lambda_code/"
  output_path = "output_lambda_zip/ami_sharing.zip"
}

# Create lambda function
resource "aws_lambda_function" "ShareAMI" {
  filename      = data.archive_file.init.output_path
  function_name = "ShareAMI"
  role          = aws_iam_role.role.arn
  handler       = "main_handler.lambda_handler"
  description   = "Get Available IP Count of a Subnet"
  tags          = { Name = "${var.name-prefix}-lambda" }

  # Prevent lambda recreation
  source_code_hash = filebase64sha256(data.archive_file.init.output_path)

  runtime = "python3.9"
  timeout = "120"

  environment {
    variables = {
      PROD = var.account_list["PROD"],
      DEV  = var.account_list["DEV"]
    }
  }
}