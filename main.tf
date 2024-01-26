######################################

# __author__ = "Daniel Benton"
# __version__ = "0.1.0"
# __license__ = "N/A"

# TO DO:
#
# [x] AWS Provider
# [x] Eventbridge: weather_trigger 
# [x] Lambda: weather_retrieve
# [x] S3: weather_landing 
# [x] Lambda: weather_etl
# [x] S3: weather_transformed
# 
######################################

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

locals {
  common_tags = {
    Owner = "D.Benton"
    Team = "i.AI"
    Project = "Interview_Q1"
    Env = "Dev"
    Budget_code = "ZZZ"
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = local.common_tags
}

# AWS EventBridge
resource "aws_cloudwatch_event_rule" "weather_trigger" {
  name = "weather-trigger"
  schedule_expression = "cron(0 5 ? * MON-FRI *)"
  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "weather_trigger_lambda" {
  rule = aws_cloudwatch_event_rule.weather_trigger.name
  target_id = "weatherRetrieveLambda"
  arn = aws_lambda_function.weather_retrieve.arn
}

resource "aws_lambda_permission" "allow_eventbridge_weather_retrieve" {
  statement_id  = "AllowExecutionFromEventBridge"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.weather_retrieve.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.weather_trigger.arn
}

# AWS Lambda (weather_retrieve)
resource "aws_lambda_function" "weather_retrieve" {
  function_name = "weatherRetrieve"
  handler = "index.handler"
  role = aws_iam_role.iam_for_lambda.arn
  runtime = "python3.8"
  
  filename = "etl_lambda_function_package.zip"
  source_code_hash = filebase64sha256("etl_lambda_function_package.zip")
  tags = local.common_tags
}

# AWS Lambda (weather_etl)
resource "aws_lambda_function" "weather_etl" {
  function_name = "weatherETL"
  handler = "etl.handler" 
  role = aws_iam_role.iam_for_lambda.arn
  runtime = "python3.8"
  
  filename = "etl_lambda_function_package.zip"
  source_code_hash = filebase64sha256("etl_lambda_function_package.zip")
  tags = local.common_tags
}

# AWS S3 Bucket (weather_landing)
resource "aws_s3_bucket" "weather_landing" {
  bucket = "weather-landing"
  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "weather_landing" {
  bucket = aws_s3_bucket.weather_landing.id

  block_public_acls = true
  ignore_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
}

# S3 Event Notification
resource "aws_s3_bucket_notification" "weather_landing_notification" {
  bucket = aws_s3_bucket.weather_landing.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.weather_etl.arn
    events = ["s3:ObjectCreated:*"]
    filter_prefix = "path/to/data/" #Add this!
    filter_suffix = ".json"
  }
}

# AWS S3 Bucket (weather_transformed)
resource "aws_s3_bucket" "weather_transformed" {
  bucket = "weather-transformed"
  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "weather_transformed" {
  bucket = aws_s3_bucket.weather_transformed.id

  block_public_acls = true
  ignore_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
}

