* See terraform workspace list
`terraform workspace list`
* Zip lambda code:
`cd lambda-src && zip -r ../function.zip * && cd ../`
* `terraform workspace create <stage>`
Create workspace if doesn't exist
but select existing one if it's already there: `terraform workspace select <stage>`
* Refresh terraform plugins:
run `terraform init`
* Deploy this using aws config so:
`terraform apply -var stage=qa`
Either `AWS_PROFILE=diversey terraform apply -var stage=dev`
OR `AWS_ACCESS_KEY_ID=<access_key> AWS_SECRET_ACCESS_KEY=<secret_key> terraform apply -var stage=dev`
