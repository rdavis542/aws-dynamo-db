variable "region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "us-east-2"
}

variable "table_name" {
  type        = string
  description = "Name of the DynamoDB table"
  default     = "app-table"
}

variable "billing_mode" {
  type        = string
  description = "DynamoDB billing mode: PAY_PER_REQUEST or PROVISIONED"
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "hash_key" {
  type        = string
  description = "Attribute name to use as the partition (hash) key"
  default     = "id"
}

variable "hash_key_type" {
  type        = string
  description = "Attribute type for the hash key: S (String), N (Number), or B (Binary)"
  default     = "S"
  validation {
    condition     = contains(["S", "N", "B"], var.hash_key_type)
    error_message = "hash_key_type must be S, N, or B."
  }
}

variable "range_key" {
  type        = string
  description = "Attribute name to use as the sort (range) key. Leave empty to omit."
  default     = ""
}

variable "range_key_type" {
  type        = string
  description = "Attribute type for the range key: S (String), N (Number), or B (Binary)"
  default     = "S"
  validation {
    condition     = contains(["S", "N", "B"], var.range_key_type)
    error_message = "range_key_type must be S, N, or B."
  }
}

variable "read_capacity" {
  type        = number
  description = "Provisioned read capacity units (only used when billing_mode is PROVISIONED)"
  default     = 5
}

variable "write_capacity" {
  type        = number
  description = "Provisioned write capacity units (only used when billing_mode is PROVISIONED)"
  default     = 5
}

variable "enable_autoscaling" {
  type        = bool
  description = "Enable autoscaling for provisioned capacity (only applies when billing_mode is PROVISIONED)"
  default     = false
}

variable "autoscaling_min_read_capacity" {
  type        = number
  description = "Minimum read capacity units for autoscaling"
  default     = 1
}

variable "autoscaling_max_read_capacity" {
  type        = number
  description = "Maximum read capacity units for autoscaling"
  default     = 20
}

variable "autoscaling_min_write_capacity" {
  type        = number
  description = "Minimum write capacity units for autoscaling"
  default     = 1
}

variable "autoscaling_max_write_capacity" {
  type        = number
  description = "Maximum write capacity units for autoscaling"
  default     = 20
}

variable "autoscaling_target_utilization" {
  type        = number
  description = "Target utilization percentage for autoscaling (0-100)"
  default     = 70
}

variable "ttl_attribute" {
  type        = string
  description = "Name of the TTL attribute. Leave empty to disable TTL."
  default     = ""
}

variable "enable_streams" {
  type        = bool
  description = "Enable DynamoDB Streams"
  default     = false
}

variable "stream_view_type" {
  type        = string
  description = "Stream view type: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES"
  default     = "NEW_AND_OLD_IMAGES"
  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "stream_view_type must be KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES."
  }
}

variable "global_secondary_indexes" {
  type = list(object({
    name               = string
    hash_key           = string
    hash_key_type      = string
    range_key          = optional(string)
    range_key_type     = optional(string)
    projection_type    = string
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  description = "List of Global Secondary Index definitions"
  default     = []
}
