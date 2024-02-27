terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "~> 3.0"
    }  
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "<= 2.0.0"
    }
    rancher2 = {
      source = "rancher/rancher2"
      version = ">= 1.10.0" 
  #access_key = "" //
  #secret_key = ""
    }
  }
}

provider "gitlab" {
  token = var.gitlab_token
  base_url = "https://gitlab.nioyatech.com/"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}


resource gitlab_project_cluster "k3s" {
  project                       = "108"
  name                          = "mlops"
  #domain                        = "http://publ_ip.nip.io"
  enabled                       = true
  kubernetes_api_url            = "https://publ_ip:6443"
  kubernetes_token              = templatefile("./token.txt", { })
  kubernetes_ca_cert            = templatefile("./cert.txt", { })
  #kubernetes_namespace          = "devops-19-dev"
  kubernetes_authorization_type = "rbac"
  environment_scope             = "*"
  #management_project_id         = "19"
  # depends_on = [ time_sleep.wait ]
  
}

#

