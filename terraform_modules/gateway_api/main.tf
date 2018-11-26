variable account_id {}
variable stage {}
variable region {}
variable function_name {}
variable function_arn {}
variable resource_path {}
variable api_name {}
variable method_name {}
variable integration_type {}


variable status_code {
  default = "200"
}

resource "aws_api_gateway_rest_api" "gateway_api" {
  name = "${var.api_name}"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway_api.id}"
  parent_id = "${aws_api_gateway_rest_api.gateway_api.root_resource_id}"
  path_part = "${var.resource_path}"
}

resource "aws_api_gateway_method" "gateway_api_method" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway_api.id}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  http_method = "${var.method_name}"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "gateway_api_method_200" {
  depends_on = ["aws_api_gateway_method.gateway_api_method"]
  rest_api_id = "${aws_api_gateway_rest_api.gateway_api.id}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  http_method = "${aws_api_gateway_method.gateway_api_method.http_method}"
  status_code = "${var.status_code}"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "gateway_api_method_integration" {
  depends_on = ["aws_api_gateway_method.gateway_api_method"]
  rest_api_id = "${aws_api_gateway_rest_api.gateway_api.id}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  http_method = "${aws_api_gateway_method.gateway_api_method.http_method}"
  integration_http_method = "POST"
  type = "${var.integration_type}"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.function_name}/invocations"
}

resource "aws_lambda_permission" "apigw_lambda" {
  depends_on = [
    "aws_api_gateway_method.gateway_api_method",
    "aws_api_gateway_integration.gateway_api_method_integration"
  ]
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.function_arn}"
  principal     = "apigateway.amazonaws.com"
  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.gateway_api.id}/*/${aws_api_gateway_integration.gateway_api_method_integration.integration_http_method}${aws_api_gateway_resource.api_resource.path}"
}

resource "aws_api_gateway_integration_response" "gateway_api_method_integration" {
  depends_on = ["aws_api_gateway_method.gateway_api_method", "aws_api_gateway_integration.gateway_api_method_integration"]
  rest_api_id = "${aws_api_gateway_rest_api.gateway_api.id}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  http_method = "${aws_api_gateway_method.gateway_api_method.http_method}"
  status_code = "${var.status_code}"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_deployment" "gateway_api" {
  depends_on = [
    "aws_api_gateway_method.gateway_api_method",
    "aws_api_gateway_integration.gateway_api_method_integration"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.gateway_api.id}"
  stage_name = "${var.stage}"
}

output "url" {
  value = "https://${aws_api_gateway_deployment.gateway_api.rest_api_id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_deployment.gateway_api.stage_name}"
}
