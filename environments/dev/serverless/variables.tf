# Variable to provide the secret from TF var/CI (never commit plain text)
variable "webhook_secret_value" {
  description = "Initial webhook shared secret"
  type = string
  sensitive = true
}