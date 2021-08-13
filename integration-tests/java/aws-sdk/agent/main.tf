module "test" {
  source = "../../../../opentelemetry-lambda/java/integration-tests/aws-sdk/agent"

  enable_collector_layer = false
  sdk_layer_name         = var.sdk_layer_name
  function_name          = var.function_name

  tracing_mode = "Active"
}

resource "aws_iam_role_policy_attachment" "test_xray" {
  role       = module.test.function_role_name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "test_amp" {
  role       = module.test.function_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusFullAccess"
}


resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "../../../amp-terraform/custom-config-layer.zip"
  layer_name = "custom_collector_config"
  compatible_runtimes = ["java11"]
}
