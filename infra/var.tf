variable "ami" {
  default = "ami-085f9c64a9b75eed5"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "medium" {
  default = "t2.medium"
}

variable "key_name" {
  default = "Ohio_key"
}

variable "subnet_id" {
  default = "subnet-058fd029faed5218f"
}

variable "iam_instance_profile" {
  default = "SessionManagerRole"
}

variable "security_groups" {
  default = ["sg-08fb45fad9561e93b"]
}