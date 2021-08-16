data "aws_region" "current" {}

module "test" {
  source = "../../../../opentelemetry-lambda/java/integration-tests/aws-sdk/agent"

  enable_collector_layer = false
  sdk_layer_name         = var.sdk_layer_name
  function_name          = var.function_name
  collector_config_layer_arn = aws_lambda_layer_version.collector_config_layer.arn
  tracing_mode = "Active"
}


# set up an AMP workspace used only for integration tests (assume customer already has their own AMP workspace endpoint)
resource "aws_prometheus_workspace" "test_amp_workspace" {

    // create a config.yaml file with the AMP "endpoint" and "region", and zips it
    provisioner "local-exec" {
        command = "sed 's@<remote_write_endpoint>@${self.prometheus_endpoint}api/v1/remote_write@g; s@<workspace_region>@${data.aws_region.current.name}@g' preformatted_config.yaml > config.yaml; zip custom-config-layer.zip config.yaml; rm config.yaml; "
    }
}

resource "aws_iam_role_policy_attachment" "test_xray" {
  role       = module.test.function_role_name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "test_amp" {
  role       = module.test.function_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusFullAccess"
}

resource "aws_lambda_layer_version" "collector_config_layer" {
  layer_name          = "custom_collector_config"
  filename            = "${path.module}/custom-config-layer.zip"
  compatible_runtimes = ["java8", "java8.al2", "java11"]
  license_info        = "Apache-2.0"
  source_code_hash    = filebase64sha256("${path.module}/custom-config-layer.zip")
}
