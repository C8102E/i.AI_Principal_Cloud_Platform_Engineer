resource "aws_s3_bucket" "weather_landing" {
  bucket = "weather-landing"
  tags   = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "weather_landing" {
  bucket = aws_s3_bucket.weather_landing.id
  block_public_acls   = true
  ignore_public_acls  = true
  block_public_policy = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "weather_landing_notification" {
  bucket = aws_s3_bucket.weather_landing.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.weather_etl.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "path/to/data/"
    filter_suffix       = ".json"
  }
}

resource "aws_s3_bucket" "weather_transformed" {
  bucket = "weather-transformed"
  tags   = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "weather_transformed" {
  bucket = aws_s3_bucket.weather_transformed.id
  block_public_acls   = true
  ignore_public_acls  = true
  block_public_policy = true
  restrict_public_buckets = true
}