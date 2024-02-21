resource "aws_cloudwatch_event_rule" "weather_trigger" {
  name                = "weather-trigger"
  schedule_expression = "cron(0 5 ? * MON-FRI *)"
  tags                = local.common_tags
}

resource "aws_cloudwatch_event_target" "weather_trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.weather_trigger.name
  target_id = "weatherRetrieveLambda"
  arn       = aws_lambda_function.weather_retrieve.arn
}

resource "aws_lambda_permission" "allow_eventbridge_weather_retrieve" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.weather_retrieve.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.weather_trigger.arn
}

