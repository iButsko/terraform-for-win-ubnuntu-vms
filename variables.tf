variable "ami" {
  type        = string
  default     = ""
  description = "image of MV"
}


variable "instance_type" {
  type        = string
  default     = ""
  description = "instance"
}
variable "subnet_id" {
  type        = string
  default     = ""
  description = "subnet fot instance"
}

variable "key_name" {
  type        = string
  default     = ""
  description = "private key for instance"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "vpc id for instance"
}

variable "name" {
  type        = string
  default     = ""
  description = "name of vm"
}

variable "from_port_in" {
  default     = ""
  description = "from wich port ingress access"
}

variable "to_port_in" {
  default     = ""
  description = "to wich port ingress access"
}

variable "protocol_in" {
  default     = ""
  description = "ingress protocol"
}

variable "from_port_en" {
  default     = ""
  description = "from wich port engress access"
}

variable "to_port_en" {
  default     = ""
  description = "to wich port engress access"
}

variable "protocol_en" {
  type        = string
  default     = ""
  description = "engress protocol"
}

variable "s3_key" {
  type        = string
  default     = ""
  description = "bucket name for jira task"
}

variable "protocol_ubuntu" {
  type        = string
  default     = ""
  description = "protocol for ubuntu instance"
}

variable "port_windows" {
  type        = list
  description = "port for windows instance"
}

variable "port_ubuntu" {
  type        = list
  description = "port for ubuntu instance"
}
variable "key_path" {
  type        = string
  default     = ""
  description = "path for local private key"
}