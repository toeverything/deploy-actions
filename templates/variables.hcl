variable "name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
}

variable "region" {
  description = "The region where jobs will be deployed"
  type        = string
  default     = "global"
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["development"]
}

variable "namespace" {
  description = "The namespace to use as the job name which overrides using the pack name"
  type        = string
  default     = "development"
}

variable "services" {
  description = "Configuration options of the AFFiNE services and checks."
  type = list(object({
    name           = string
    image          = string
    tag            = string
    port           = list(object({ name = string, to = number, domain = string }))
    envs           = list(object({ key = string, value = string }))
    check_type     = string
    check_path     = string
    check_interval = string
    check_timeout  = string
    cpu            = number, # MHz
    memory         = number, # MB
  }))

  default = []
}
