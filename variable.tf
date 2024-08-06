variable "vpc_cidr" {
    description = "cidr for vpc" 
    type = string
}
variable "public_subnet_cidr_block" {
    description = "cidr for public subnet"
    type = string

  
}
variable "private_subnet_cidr_block" {
  description = "cidr for private subnet"
  type = string
}
variable "aws_instance_ami" {
  description = "ami id for instance"
  type = string
  
}
variable "my_instance_type" {
  description = "instance type for instance"
  type = string
}
variable "public_availability_zone" {
  description = "Availability zone for instance"
  type = string
  
}
variable "private_availability_zone" {
  description = "private availability zone"
  type = string
  
}