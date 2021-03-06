variable "codebase" {
  description = "Absolute path to the directory containing the codebase for this function."
  type        = string
}

variable "name" {
  description = "The name of the lambda function"
  type        = string
}

variable "name_prefix" {
  description = "A prefix for the docker repo this module creates"
  type        = string
}

variable "tags" {
  description = "The AWS tags to apply to all infrastructure"
  type        = map(string)
}

variable "handler" {
  description = "The function that will be called when the lambda executes."
  type        = string
  default     = "main.handler"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "local_file" "requirements-txt" {
  filename = "${var.codebase}/requirements.txt"
}

locals {
  base_image        = "public.ecr.aws/lambda/python:3.8"
  runtime           = "python3.8"
  tags              = merge(var.tags, {})
  ecr_hostname      = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
  image_tag         = sha256(join("", [data.archive_file.codebase.output_md5, data.docker_registry_image.image.sha256_digest]))
  function_name     = "${var.name_prefix}-${var.name}"
  remote_image_name = "${local.ecr_hostname}/${local.function_name}:${local.image_tag}"
}
