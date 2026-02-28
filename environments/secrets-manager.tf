resource "aws_secretsmanager_secret" "webhook_secret" {
  name                    = "webhook/secret"
  description             = "Shared secret used to verify incoming webhooks"
  recovery_window_in_days = 0 # set as needed (0 means force-delete without recovery)
  # kms_key_id = aws_kms_key.secrets_key.arn # optional: custom CMK if you don't want AWS managed key
}

# Initial secret value (you can also import from an external var or CI/CD)
resource "aws_secretsmanager_secret_version" "webhook_secret_v1" {
  secret_id     = aws_secretsmanager_secret.webhook_secret.id
  secret_string = var.webhook_secret_value
}

