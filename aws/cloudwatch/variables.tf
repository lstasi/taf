variable "name_prefix" {
  description = "Prefix applied to the names of all CloudWatch resources created by this module"
  type        = string
  default     = "free-tier"
}

variable "log_groups" {
  description = "Map of log group names to their configuration. Always-free: 5 GB ingestion/month"
  type = map(object({
    retention_in_days = optional(number, 14)
  }))
  default = {}
}

variable "alarms" {
  description = "Map of CloudWatch metric alarm definitions. Always-free: 10 alarms/month"
  type = map(object({
    alarm_description   = optional(string, "")
    namespace           = string
    metric_name         = string
    dimensions          = optional(map(string), {})
    comparison_operator = optional(string, "GreaterThanOrEqualToThreshold")
    statistic           = optional(string, "Average")
    period              = optional(number, 300)
    evaluation_periods  = optional(number, 1)
    threshold           = number
    treat_missing_data  = optional(string, "notBreaching")
    sns_topic_arn       = optional(string, "")
  }))
  default = {}
}

variable "dashboard_name" {
  description = "Name for the CloudWatch dashboard. Leave empty to skip dashboard creation. Always-free: 3 dashboards/month"
  type        = string
  default     = ""
}

variable "dashboard_body" {
  description = "JSON body of the CloudWatch dashboard. Required when dashboard_name is set"
  type        = string
  default     = "{\"widgets\":[]}"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
