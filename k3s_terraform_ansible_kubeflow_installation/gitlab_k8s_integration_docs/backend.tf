terraform {
  backend "s3" {
    bucket = "mlops-k3s"
    key = "project/dev-mlops/remote-backend.tfstate-sj"
    region = "us-east-1"
    encrypt = true
  }

}

