variable "region" {
  default = ""
}

variable "alb-name" {
  default = ""
}

variable "internal" {
  default = ""
}

variable "alb-sg" {
  default = ""
}

variable "alb-subnets" {
  type = list(string)
}

variable "alb-tag" {
  default = ""
}


#TARGET GROUPS

variable "tg-name" {
  default = ""
}

variable "port" {
  default = ""
}

variable "protocol" {
  default = ""
}

variable "vpc-id" {
  default = ""
}

variable "no-of-frontend-attachments" {
  type = list(string)
}
/*
variable "certificate-arn" {
  default = ""
}
*/