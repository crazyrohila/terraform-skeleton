terraform {
  backend "s3" {
    bucket = "lambdas-terraform-states"
    region = "eu-west-1"
  }
}

resource "aws_lambda_function" "skeleton_lambda" {
  function_name = "skeleton_lambda_${var.stage}"
  handler = "${var.lambda_handler}"

  runtime = "${var.runtime}"
  memory_size = "${var.memory_size}"
  timeout = "${var.timeout}"
  filename = "${var.filename}"
  source_code_hash = "${base64sha256(file("${var.filename}"))}"
  role = "${var.iam_role}"
  environment {
    variables = "${merge(var.env_vars,
      map("FOO_OTHER", var.foo_other)
    )}"
  }
  vpc_config {
    subnet_ids = "${var.subnet_ids}"
    security_group_ids = "${var.security_group_ids}"
  }
}

module "skeleton_gateway_api" {
  source = "./terraform_modules/gateway_api"
  api_name = "${var.api_name}"
  resource_path = "${var.resource_path}"
  method_name = "${var.method_name}"
  region = "${var.region}"
  stage = "${var.stage}"
  function_name = "${aws_lambda_function.skeleton_lambda.function_name}"
  function_arn = "${aws_lambda_function.skeleton_lambda.arn}"
  account_id = "${var.account_id}"
  integration_type = "${var.integration_type}"
}

output "lambda_function_name" {
  value = "${aws_lambda_function.skeleton_lambda.function_name}"
}

output "api_gateway" {
  value = "${module.skeleton_gateway_api.url}"
}
