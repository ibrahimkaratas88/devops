variable "PROJECT_IDENTIFIER"{
    type = string
    default = "TEST"
}

variable "REGION"{
    type = string
    default = "eu-central-1"
}

variable "VOLUME_SIZE"{
    type = number
    default = 32
}

variable "VOLUME_TYPE"{
    type = string
    default = "gp3"
}

variable "AMI_ID"{
    type = string
    default = "ami-05f7491af5eef733a"
}

variable "INSTANCE_TYPE"{
    type = string
    default = "t3a.medium"
}

variable "KEY_NAME"{
    type = string
    default = "mattseukey"
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
    default = "vpc-099333c993680a035"
}

variable "SUBNET_1"{
    type = string
    default = "subnet-0b3d4b8909fdba8c5"
}

variable "SUBNET_2"{
    type = string
    default = "subnet-04e73f63c24d9c816"
}

variable "KUBE_MASTER_AZ"{
    type = string
    default = "eu-central-1a" 
}

variable "KUBE_MASTER_SUBNET_ID"{
    type = string
    default = "subnet-0b3d4b8909fdba8c5"
}

variable "LISTENER_PORT"{
    type = string
    default = "6443"
}

variable "TARGET_GROUP_PORT"{
    type = number
    default = 6443
}










