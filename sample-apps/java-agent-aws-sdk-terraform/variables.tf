variable "function_name" {
  type        = string
  description = "Name of sample app function / API gateway"
  default     = "hello-java-awssdk-agent"
}

variable "path_to_custom_collector_config_zip" {
  type        = string
  description = "The relative path to the zip file containing a custom collector configuration, named config.yaml, with your own AMP remote write endpoint and region written in. Leave as default to use the default collector config (no AMP enabled)"
  default = null 
}
