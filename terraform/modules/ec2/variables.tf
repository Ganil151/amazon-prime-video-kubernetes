variable "instance_name" {
  description = "Name tag for the instance"
  type        = string
  default     = "Jenkins-Server"
}

variable "ami_id" {
  description = "AMI ID to use for the instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type to use"
  type        = string
  default     = "t3.large"
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with"
  type        = list(string)
}

variable "key_name" {
  description = "Key pair name to use for SSH access"
  type        = string
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 15
}

variable "root_volume_type" {
  description = "Type of the root volume (e.g., gp2, gp3)"
  type        = string
  default     = "gp3"
}

variable "user_data" {
  description = "User data script to initialize the instance"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Whether to replace the instance when user data changes"
  type        = bool
  default     = true
}
