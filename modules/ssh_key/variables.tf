variable "create" {
  description = "Whether Terraform should generate and register a new SSH key."
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Name of the EC2 key pair to create or reuse."
  type        = string

  validation {
    condition     = length(trimspace(var.key_name)) > 0
    error_message = "key_name must not be empty."
  }
}

variable "private_key_filename" {
  description = "Local destination for the generated private key."
  type        = string
}

variable "private_key_file_permission" {
  description = "Filesystem permission for the generated private key."
  type        = string
  default     = "0600"
}

variable "rsa_bits" {
  description = "Size of the generated RSA key."
  type        = number
  default     = 2048

  validation {
    condition     = var.rsa_bits >= 2048 && var.rsa_bits == floor(var.rsa_bits)
    error_message = "rsa_bits must be a whole number of at least 2048."
  }
}

variable "tags" {
  description = "Additional tags for the AWS key pair."
  type        = map(string)
  default     = {}
}
