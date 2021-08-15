data "aws_region" "current" {}

module "app" {
  source = "../../opentelemetry-lambda/java/sample-apps/aws-sdk/deploy/agent"

  name                = var.function_name
  collector_layer_arn = null
  sdk_layer_arn       = lookup(local.sdk_layer_arns, data.aws_region.current.name, "invalid")
  collector_config_layer_arn = var.path_to_custom_collector_config_zip == null ? null : aws_lambda_layer_version.collector_config_layer[0].arn
  tracing_mode        = "Active"
}

resource "aws_iam_role_policy_attachment" "test_xray" {
  role       = module.app.function_role_name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "test_amp" {
  role       = module.app.function_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusFullAccess"
}

resource "aws_lambda_layer_version" "collector_config_layer" {
  count               = var.path_to_custom_collector_config_zip == null? 0 : 1
  layer_name          = "custom_collector_config"
  filename            = var.path_to_custom_collector_config_zip
  compatible_runtimes = ["java8", "java8.al2", "java11"]
  license_info        = "Apache-2.0"
  source_code_hash    = filebase64sha256(var.path_to_custom_collector_config_zip)
}
