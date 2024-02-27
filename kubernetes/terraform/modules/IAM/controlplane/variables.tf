variable "PROJECT_IDENTIFIER"{
    type = string
    default = "MLOPS"
}

variable "REGION"{
    type = string
    default = "us-east-1"
}

variable "VOLUME_SIZE"{
    type = number
    default = 20
}

variable "VOLUME_TYPE"{
    type = string
    default = "gp3"
}

variable "AMI_ID"{
    type = string
    default = "ami-04505e74c0741db8d"
}

variable "INSTANCE_TYPE"{
    type = string
    default = "t3.large"
}

variable "KEY_NAME"{
    type = string
    default = "mlops"
}

variable "DESIRED_CAPACITY_CTRLPLANE"{
    type = number
    default = 2
}

variable "MAX_SIZE_CTRLPLANE"{
    type = number
    default = 4
}

variable "MIN_SIZE_CTRLPLANE"{
    type = number
    default = 2
}

variable "DESIRED_CAPACITY_WORKER_1"{
    type = number
    default = 1
}

variable "MAX_SIZE_WORKER_1"{
    type = number
    default = 3
}

variable "MIN_SIZE_WORKER_1"{
    type = number
    default = 1
}

variable "DESIRED_CAPACITY_WORKER_2"{
    type = number
    default = 1
}

variable "MAX_SIZE_WORKER_2"{
    type = number
    default = 3
}

variable "MIN_SIZE_WORKER_2"{
    type = number
    default = 1
}

variable "VPC_ID"{
    type = string
    default = "vpc-092a05d1eb8c90f67"
}

variable "SUBNET_1"{
    type = string
    default = "subnet-02957de2e70d0ebe0"
}

variable "SUBNET_2"{
    type = string
    default = "subnet-091e0db9ba81cf194"
}

variable "SUBNET_3"{
    type = string
    default = "subnet-07317d4533f0896af"
}

variable "SUBNET_4"{
    type = string
    default = "subnet-057072f1cff1d3f97"
}

variable "SUBNET_5"{
    type = string
    default = "subnet-02ba9f74464a4fadc"
}

variable "SUBNET_6"{
    type = string
    default = "subnet-0016942c4155e3493"
}
variable "KUBE_MASTER_AZ"{
    type = string
    default = "us-east-1a" 
}

variable "KUBE_MASTER_SUBNET_ID"{
    type = string
    default = "subnet-0016942c4155e3493"
}

variable "LISTENER_PORT"{
    type = string
    default = "6443"
}

variable "TARGET_GROUP_PORT"{
    type = number
    default = 6443
}










