#terraform {
  #backend "http" {
  #}
#}
provider "gitlab" {
  token = var.gitlab_token
  base_url = "https://gitlab.nioyatech.com/"
}

terraform {
  backend "s3" {
    bucket = "mlops-k3s"
    key = "project/dev-mlops/remote-backend.tfstate"
    region = "us-east-1"
    #access_key = ${AWS_ACCESS_KEY}
    #secret_key = ${AWS_SECRET_ACCESS_KEY}
    #encrypt = true
  }

}
##
#####
###
####
######

