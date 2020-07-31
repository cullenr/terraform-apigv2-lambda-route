resource "aws_iam_role" "this" {
  name = "${var.name}_apig_exec"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "this" {
  name = "${var.name}_apig_exec"
  path = "/"
  description = "IAM policy for logging and s3 from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource":
"arn:aws:lambda:eu-west-2:*:function:${aws_lambda_function.this.function_name}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  role = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_lambda_function" "this" {
  filename      = var.function_filename
  function_name = var.name
  role          = aws_iam_role.this.arn
  handler       = "index.handler"
  runtime       = "nodejs10.x"
}

resource "aws_apigatewayv2_route" "this" {
  route_key             = var.route_key
  api_id                = var.api_id
  authorization_scopes  = var.authorization_scopes
  authorization_type    = "JWT"
  authorizer_id         = var.authorizer_id

  # https://github.com/terraform-providers/terraform-provider-aws/issues/12972
  # The integration must be specified here otherwise the link will not be made -
  # outside of 'quick create' this option is mandatory - contra to the docs
  # recommendation
  target = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_integration" "this" {
  api_id           = var.api_id
  integration_type = "AWS_PROXY"

  description               = "Lambda test function"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.this.invoke_arn
  payload_format_version    = "2.0"
}

resource "aws_lambda_permission" "this" {
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.this.arn
    principal     = "apigateway.amazonaws.com"

    source_arn = "${var.api_execution_arn}/*/*"
}
