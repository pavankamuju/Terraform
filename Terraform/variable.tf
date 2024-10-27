variable "cidr" {
    description = "cidr block for myvpc"
    type = string
}

variable "ami_id" {
  description = "ami for ec2 instance"
  type = string
}

variable "instance_value" {
  description = "Ec2 instance type"
  type = string
}

variable "key_pair_value" {
  description = "key value for Ec2 Iinstance"
  type = string  
}
