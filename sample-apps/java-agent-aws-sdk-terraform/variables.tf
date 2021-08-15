variable "function_name" {
  type        = string
  description = "Name of sample app function / API gateway"
  default     = "hello-java-awssdk-agent"
}

variable "path_to_custom_collector_config_zip" {
  type        = string
  description = "File path to the zipped custom collector config.yaml file. Leave as empty to use the default config (without an AMP endpoint)"
  default     = "../../integration-tests/amp-terraform/custom-config-layer.zip" 
  // default = null
  // remove default after finish testing
}
