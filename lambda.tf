resource "aws_lambda_function" "weather_retrieve" {
  function_name    = "weatherRetrieve"
  handler          = "index.handler"
  role             = aws_iam_role.iam_for_lambda.arn
  runtime          = "python3.8"
  filename         = "etl_lambda_function_package.zip"
  source_code_hash = filebase64sha256("etl_lambda_function_package.zip")
  tags             = local.common_tags
}

resource "aws_lambda_function" "weather_etl" {
  function_name    = "weatherETL"
  handler          = "etl.handler"
  role             = aws_iam_role.iam_for_lambda.arn
  runtime          = "python3.8"
  filename         = "etl_lambda_function_package.zip"
  source_code_hash = filebase64sha256("etl_lambda_function_package.zip")
  tags             = local.common_tags
}
