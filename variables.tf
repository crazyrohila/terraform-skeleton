variable stage {
  default = "dev"
}
variable region {
  default = "eu-west-1"
}

# variable access_key {}
# variable secret_key {}
# gateway api variables
variable api_name {
  default = ""
}
variable resource_path {
  default = ""
}
variable account_id {
  default = ""
}
variable method_name {
  default = "GET"
}
variable integration_type {
  default = "AWS"
}

#lambda variables
variable lambda_handler {
  default = "main.lambda_handler"
}
variable runtime {
  default = "python3.6"
}
variable memory_size {
  default = 512
}
variable timeout {
  default = 300
}
variable filename {
  default = "function.zip"
}
variable iam_role {
  default = "lambda_role_ARN"
}
variable subnet_ids {
  type = "list"
  default = ["subnet-a", "subnet-b"]
}
variable security_group_ids {
  type = "list"
  default = ["sg-a"]
}
# merge this secret variables with env_vars, check main.tf
variable foo_other {
  default = ""
}

variable env_vars {
  type = "map"
  default = {}
}

provider "aws" {
  region = "${var.region}"
}
