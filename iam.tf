/* IAM Role: Allow Lambda to perform Publish operations on SNS, Get Secrets from Secret Manager, send Logs and PUT Metrics to CloudWatch . */

data "aws_iam_policy_document" "policy_source" {
  statement {
    sid    = "CloudWatchAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    sid    = "ShareAMI"
    effect = "Allow"
    actions = [
      "ec2:DescribeImageAttribute",
      "ec2:ModifyImageAttribute"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "role_source" {
  statement {
    sid    = "LambdaAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM Policy
resource "aws_iam_policy" "policy" {
  name        = "ShareAMI_policy"
  path        = "/"
  description = "StartOutbound using Lambda"
  policy      = data.aws_iam_policy_document.policy_source.json
  tags        = { Name = "${var.name-prefix}-policy" }
}

# IAM Role (Lambda execution role)
resource "aws_iam_role" "role" {
  name               = "ShareAMI_policy_role"
  assume_role_policy = data.aws_iam_policy_document.role_source.json
  tags               = { Name = "${var.name-prefix}-role" }
}

# Attach Role and Policy
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}