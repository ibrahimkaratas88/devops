#variable "prefix" {
  #description = "Prefix for deploy for aws resources`."
  #default = "k3sdev"
#}

#variable "mysql_inst_type" {
  #default = "db.t2.micro"
#}

#variable "mysql_username" {
  #default = "admin"
#}

#variable "m_num_servers" {
  #description = "Number of master server instances to deploy (2 recommended)."
  #default = "1"
#}

# variable "a_num_servers" {
#   description = "Number of agent/worker server instances to deploy."
#   default = "1"
# }

variable "access_key" {
  default = "XXXXXXXXXXXXXXXXX"
}

variable "secret_key" {
  default = "XXXXXXXXXXXXXXXXXXX"
}

variable "gitlab_token" {
  default = "XXXXXXXXXXXXXXXXX"
}
