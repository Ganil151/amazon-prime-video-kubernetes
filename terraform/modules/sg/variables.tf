variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
  default     = "web-sg"
}

variable "allowed_ingress_ports" {
  description = "List of ingress ports to allow"
  type        = list(number)
  default     = [22, 80, 443]
}
