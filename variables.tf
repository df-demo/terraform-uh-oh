variable "region" {
  type    = string
  default = "us-west-1"
}

variable "ami" {
  type    = string
  description = "AMI used for the EC2 instance"
  default = "ami-07336266b2c69c546"
}

variable "access_key" {
  type    = string
}

variable "secret_key" {
  type    = string
}

variable "s3_acl" {
  type = string
  default = "public-read-write"
}

variable "env" {
  type = string
  default = "dev"
}
