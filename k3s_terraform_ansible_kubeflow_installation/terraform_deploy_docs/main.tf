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
      version = ">= 2.0.0"
    }
    #kubernetes = {
      #source  = "registry.terraform.io/hashicorp/kubernetes"
      #version = "~> 1.0"
    #}
    #helm = {
      #version = "~> 1.0"
    #}
    
    #rancher2 = {
      #source = "rancher/rancher2"
      #version = ">= 1.10.0" 
  #access_key = "" //
  #secret_key = ""
    #}
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "gitlab" {
  token = var.gitlab_token
  base_url = "https://gitlab.nioyatech.com/"
}

#provider "helm" {
  #kubernetes {
    #load_config_file       = false
    #host = "https://18.118.110.224:6443"
    #config_path = "~/.kube/config"
    #config_context =  data.
    #config_path = "/etc/rancher/k3s/k3s.yaml"
    #client_certificate     = "$HOME/.kube/client-cert.pem"
    #client_key             = "$HOME/.kube/client-key.pem"
    #cluster_ca_certificate = "$HOME/.kube/cluster-ca-cert.pem"
    #client_certificate     = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJrVENDQVRlZ0F3SUJBZ0lJQ3RtUUJSY29aZ1V3Q2dZSUtvWkl6ajBFQXdJd0l6RWhNQjhHQTFVRUF3d1kKYXpOekxXTnNhV1Z1ZEMxallVQXhOak13TWpVeU5USTRNQjRYRFRJeE1EZ3lPVEUxTlRVeU9Gb1hEVEl5TURneQpPVEUxTlRVeU9Gb3dNREVYTUJVR0ExVUVDaE1PYzNsemRHVnRPbTFoYzNSbGNuTXhGVEFUQmdOVkJBTVRESE41CmMzUmxiVHBoWkcxcGJqQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJIOWMxYTk1dEN6SlNIS0wKekJmNlBLYXdrTThJRzFCQlI5dmpKOGs3dHRvQU5Kak1WVUZkekRUa0pTYkhqb0UvcGVvVkFHTGwxOVc5bnBOMgpOKytHMXlTalNEQkdNQTRHQTFVZER3RUIvd1FFQXdJRm9EQVRCZ05WSFNVRUREQUtCZ2dyQmdFRkJRY0RBakFmCkJnTlZIU01FR0RBV2dCVGttZGtOQW1MK255NmZrUmdURTk4d2VRNmdEVEFLQmdncWhrak9QUVFEQWdOSUFEQkYKQWlBb1FGb1Fkc0tSZnZMRGVXbEtrNTZxVTBka2VwSWlFNDdDMFMzOSt0bW5vd0loQU16Vis5Mlp1aHB3QkN5WApjSXhUMVRxK2pKS3MwY21JN01BYmZYR0lsbVlxCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0KLS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJkekNDQVIyZ0F3SUJBZ0lCQURBS0JnZ3Foa2pPUFFRREFqQWpNU0V3SHdZRFZRUUREQmhyTTNNdFkyeHAKWlc1MExXTmhRREUyTXpBeU5USTFNamd3SGhjTk1qRXdPREk1TVRVMU5USTRXaGNOTXpFd09ESTNNVFUxTlRJNApXakFqTVNFd0h3WURWUVFEREJock0zTXRZMnhwWlc1MExXTmhRREUyTXpBeU5USTFNamd3V1RBVEJnY3Foa2pPClBRSUJCZ2dxaGtqT1BRTUJCd05DQUFRVzJNTzIzSEdrRk90akVjb1hTK1dZb2d2ZGxrQ3NnYmh2QVc2RGgzTFUKdkVGUjllcGN6amhzYURqcDBiZnQxcUJ3bFU5bGgxczgzV0ZQWUo3dDhxa1VvMEl3UURBT0JnTlZIUThCQWY4RQpCQU1DQXFRd0R3WURWUjBUQVFIL0JBVXdBd0VCL3pBZEJnTlZIUTRFRmdRVTVKblpEUUppL3A4dW41RVlFeFBmCk1Ia09vQTB3Q2dZSUtvWkl6ajBFQXdJRFNBQXdSUUlnTW9zVzRNUzI4eklqdWhhcTRUV05jaWtIaEhBRzFEN0IKTmpJa1pIWS9GWkFDSVFDWDlWdExmWWpCdzlVREcrdGczd1Vkam9GMWVsRFhRQUJrWi9uQTRkNERKQT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
    #client_key             = "LS0tLS1CRUdJTiBFQyBQUklWQVRFIEtFWS0tLS0tCk1IY0NBUUVFSVBXNFczdFR2djcvNWJtRTRxNVV5dnA3SExqQVpUMzJNd0taYU9qdTRjbW9vQW9HQ0NxR1NNNDkKQXdFSG9VUURRZ0FFZjF6VnIzbTBMTWxJY292TUYvbzhwckNRendnYlVFRkgyK01ueVR1MjJnQTBtTXhWUVYzTQpOT1FsSnNlT2dUK2w2aFVBWXVYWDFiMmVrM1kzNzRiWEpBPT0KLS0tLS1FTkQgRUMgUFJJVkFURSBLRVktLS0tLQo="
    #cluster_ca_certificate = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJkekNDQVIyZ0F3SUJBZ0lCQURBS0JnZ3Foa2pPUFFRREFqQWpNU0V3SHdZRFZRUUREQmhyTTNNdGMyVnkKZG1WeUxXTmhRREUyTXpBeU5USTFNamd3SGhjTk1qRXdPREk1TVRVMU5USTRXaGNOTXpFd09ESTNNVFUxTlRJNApXakFqTVNFd0h3WURWUVFEREJock0zTXRjMlZ5ZG1WeUxXTmhRREUyTXpBeU5USTFNamd3V1RBVEJnY3Foa2pPClBRSUJCZ2dxaGtqT1BRTUJCd05DQUFUa1htQy94MCtRTW50MFBJOWJWVlgvcmpFZkhzZktZVDcyQnA2Z2labWcKVG1Rc1puR1pacDd2WFI0WnJEZ3FBUWdlTW04akk5Nk5VSlpZVkx0Zk1zVGxvMEl3UURBT0JnTlZIUThCQWY4RQpCQU1DQXFRd0R3WURWUjBUQVFIL0JBVXdBd0VCL3pBZEJnTlZIUTRFRmdRVWxGa0dpeEZlYi9uYjF5N3pYUG5aCjFVZ0Z2dzB3Q2dZSUtvWkl6ajBFQXdJRFNBQXdSUUloQUxCRi8yRmY1S1NuMnVuaGxJQjBFNnlHdW1zTzZONGcKUEZPSVNQS1B5OUhDQWlCRVV6ZGZwTHBBVEZHMDhNZ3hja3pnYWVaNzd5L0hUREdtUFU3Um5oWmxnQT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"


  #}
#}
# module "k3s_cluster" {
#   source = "../terraform_docs"
# }


provider "kubernetes" {
  #load_config_file = false
  #config_path = "$HOME/.kube/config"
  host="https://${aws_instance.master[0].public_ip}:6443"
  #host = "https://127.0.0.1:6443"
  #config_path = file("/etc/rancher/k3s/k3s.yaml")
  #client_certificate     = file("/var/lib/rancher/k3s/server/tls/client-ca.crt")
  #client_key             = file("/var/lib/rancher/k3s/server/tls/client-ca.key")
  #cluster_ca_certificate = file("/var/lib/rancher/k3s/server/tls/server-ca.crt")
  #client_certificate     = "-----BEGIN CERTIFICATE-----MIIBdzCCAR2gAwIBAgIBADAKBggqhkjOPQQDAjAjMSEwHwYDVQQDDBhrM3MtY2xpZW50LWNhQDE2MzAyNTI1MjgwHhcNMjEwODI5MTU1NTI4WhcNMzEwODI3MTU1NTI4WjAjMSEwHwYDVQQDDBhrM3MtY2xpZW50LWNhQDE2MzAyNTI1MjgwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQW2MO23HGkFOtjEcoXS+WYogvdlkCsgbhvAW6Dh3LUvEFR9epczjhsaDjp0bft1qBwlU9lh1s83WFPYJ7t8qkUo0IwQDAOBgNVHQ8BAf8EBAMCAqQwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU5JnZDQJi/p8un5EYExPfMHkOoA0wCgYIKoZIzj0EAwIDSAAwRQIgMosW4MS28zIjuhaq4TWNcikHhHAG1D7BNjIkZHY/FZACIQCX9VtLfYjBw9UDG+tg3wUdjoF1elDXQABkZ/nA4d4DJA==-----END CERTIFICATE-----"
  #client_key             = "-----BEGIN EC PRIVATE KEY-----MHcCAQEEIA0LEFcTijYl2R+KFSs/JMCDodh5zBG1n7WfuRKfU42BoAoGCCqGSM49AwEHoUQDQgAEFtjDttxxpBTrYxHKF0vlmKIL3ZZArIG4bwFug4dy1LxBUfXqXM44bGg46dG37dagcJVPZYdbPN1hT2Ce7fKpFA==-----END EC PRIVATE KEY-----"
  #cluster_ca_certificate = "-----BEGIN CERTIFICATE-----MIIBdzCCAR2gAwIBAgIBADAKBggqhkjOPQQDAjAjMSEwHwYDVQQDDBhrM3Mtc2VydmVyLWNhQDE2MzAyNTI1MjgwHhcNMjEwODI5MTU1NTI4WhcNMzEwODI3MTU1NTI4WjAjMSEwHwYDVQQDDBhrM3Mtc2VydmVyLWNhQDE2MzAyNTI1MjgwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAATkXmC/x0+QMnt0PI9bVVX/rjEfHsfKYT72Bp6giZmgTmQsZnGZZp7vXR4ZrDgqAQgeMm8jI96NUJZYVLtfMsTlo0IwQDAOBgNVHQ8BAf8EBAMCAqQwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUlFkGixFeb/nb1y7zXPnZ1UgFvw0wCgYIKoZIzj0EAwIDSAAwRQIhALBF/2Ff5KSn2unhlIB0E6yGumsO6N4gPFOISPKPy9HCAiBEUzdfpLpATFG08MgxckzgaeZ77y/HTDGmPU7RnhZlgA==-----END CERTIFICATE-----"
  # client_certificate     = "${path.module}/.kube/client-cert.pem"
  # client_key             = "${path.module}/.kube/client-key.pem"
  # cluster_ca_certificate = "${path.module}/.kube/cluster-ca-cert.pem"
  client_certificate     = "file(~/.kube/client-cert.pem)"
  client_key             = "file(~/.kube/client-key.pem)"
  cluster_ca_certificate = "file(~/.kube/cluster-ca-cert.pem)"
}



resource "kubernetes_service_account" "gitlab" {
  metadata {
    name = "gitlab"
    namespace = "kube-system"
  }
  depends_on = [ provider.kubernetes ]
}

data "kubernetes_secret" "gitlab-token" {
  metadata {
    name = kubernetes_service_account.gitlab.default_secret_name
    namespace = kubernetes_service_account.gitlab.metadata[0].namespace
  }
}

resource gitlab_project_cluster "k3s-dev" {
  project                       = "108"
  name                          = "mlops"
  #domain                        = aws_launch_template.spotworker.tag_specifications[0].tags.k3sWorker-LT-spot.public_ip
  enabled                       = true
  kubernetes_api_url            = "https://${aws_instance.master[0].public_ip}:6443"
  kubernetes_token              = data.kubernetes_secret.gitlab-token.data.token
  kubernetes_ca_cert            = data.kubernetes_secret.gitlab-token.data["ca.crt"]
  kubernetes_namespace          = "devops"
  kubernetes_authorization_type = "rbac"
  environment_scope             = "*"
  #management_project_id         = "19"
  depends_on = [ time_sleep.wait ]
  
  
}




#provider "rancher2" {
  #host = "https://127.0.0.1:6443" 
  #access_key = "" //
  #secret_key = ""
#}

# resource "kubernetes_deployment" "projectx" {
#   metadata {
#     name = "nginx"
#     labels = {
#       nginx_service = "nginx"
#     }
#     #namespace= "devops-19-dev"
#     annotations = {
#       "app.gitlab.com/app"= "$CI_PROJECT_PATH_SLUG"
#       "app.gitlab.com/env"= "$CI_ENVIRONMENT_SLUG"      
#     }
#   }

#   spec {
#     replicas = 2

#     selector {
#       match_labels = {
#         nginx_service = "nginx"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           nginx_service = "nginx"
#         }
#         annotations = {
#           "app.gitlab.com/app"= "$CI_PROJECT_PATH_SLUG"
#           "app.gitlab.com/env"= "$CI_ENVIRONMENT_SLUG"      
#         }
#       }

#       spec {
#         container {
#           image = "nginx"
#           name  = "nginx-container"
#           port {
#             container_port = 80
#           }
#         } 
#         restart_policy = "Always"
#       }
#     }
#   }
#   #depends_on = [ aws_instance.worker ]
# }

# resource "kubernetes_ingress" "projectx" {
#   metadata {
#     name = "nginx"
#     #namespace= "devops-19-dev"
#     labels = {
#       nginx_service = "nginx"
#     }
#     annotations = {
#       "app.gitlab.com/app"= "$CI_PROJECT_PATH_SLUG"
#       "app.gitlab.com/env"= "$CI_ENVIRONMENT_SLUG"      
#     }  
#   }

#   spec {
#     rule {
#       host = ${module.k3s_cluster.output.masters_public_ip}.nip.io
#       #host = "3.128.184.170.nip.io"
#       http {
#         path {
#           #pathtype = "Prefix"
#           path = "/"
#           backend {
#             service_name = "nginx"
#             service_port = 80
#           }
#         }
#       }
#     }
#   }
#   depends_on = [ kubernetes_deployment.projectx ]
# }

# resource "kubernetes_service" "projectx" {
#   metadata {
#     name = "nginx"
#     #namespace= "devops-19-dev"
#     labels= {
#       nginx_service = "nginx"
#     }
#     annotations = {
#       "app.gitlab.com/app"= "$CI_PROJECT_PATH_SLUG"
#       "app.gitlab.com/env"= "$CI_ENVIRONMENT_SLUG"      
#     } 
#   }
#   spec {
#     selector = {
#       nginx_service = "nginx"
#     }
  
#     port {
#       name= "http"
#       port        = 80
#       target_port = 80
#     }
#   }
#   depends_on = [ kubernetes_ingress.projectx ]
# }