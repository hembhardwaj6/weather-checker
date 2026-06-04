# This is where you put your variables declaration

variable "ami_id" {
  description = "This is the ami id to be used in ec2."
  type        = string
}

variable "key_pair_name" {
  description = "this is the key pair name for ec2 instance."
  type        = string
}

variable "instance_type" {
  description = "this is the type of instance eg: t2.micro, t2.medium"
  type        = string
}

variable "public_key" {
  description = "this is the public key to be used to create a key pair."
  type        = string
  default     = ""
}

variable "sg_name" {
  type        = string
  description = "name of security group."
}

variable "application" {
  type    = string
  default = ""
}

variable "availability_zone" {
  type    = string
  default = ""
}

variable "instance_name" {
  description = "this is the name of instance."
  type        = string
  default     = "weather-checker"
}

