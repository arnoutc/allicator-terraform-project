variable "aws_account_id" {
  type = string
}
variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(any)
}

variable "private_subnets" {
  type = list(any)
}

variable "public_subnets" {
  type = list(any)
}

# Variable to provide the secret from TF var/CI (never commit plain text)
variable "webhook_secret_value" {
  description = "Initial webhook shared secret"
  type        = string
  sensitive   = true
}

variable "event_bus_name" {
  description = "Eventbridge bus name (use 'default' for the default bus)"
  type        = string
  default     = "webhook-bus"
}

variable "event_source" {
  description = "The 'source' field used by the ingress lambda when putting events"
  type        = string
  default     = "webhook.ingress"
}

variable "event_detail_types" {
  description = "A list of detail-types to route (e.g., Stripe Github event types); use ['webhook.event'] for generic"
  type        = list(string)
  default     = ["webhook.event", "order.created", "order.updated"]
}

variable "dlq_name" {
  description = "SQS queue name used as EventBridge target DLQ"
  type        = string
  default     = "eventbridge-webhooks-dlq"
}