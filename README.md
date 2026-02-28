
# Terraform Template Repository

This repository contains reusable Terraform configurations for infrastructure as code.

## Structure

Multi-account setup

### Main
To create the environment, run the command line:

```
ENV=main make plan
terraform apply main.plan
```
To destroy the environment:
```
ENV=main make destroy
```
### Dev
To create the environment, run the command line:
```
ENV=dev make plan
terraform apply dev.plan
```
To destroy the environment:
```
ENV=dev make destroy
```
# Terraform Template Repository

This repository contains reusable Terraform configurations for infrastructure as code.

# Proof Of Concepts:

## Web-hook to AWS API Gateway to Lambda

Sample payload

```
{
  "id": "evt_1234567890",
  "type": "order.created",
  "created_at": "2026-02-28T16:40:00Z",
  "data": {
    "order_id": "ORD-98765",
    "amount": 129.99,
    "currency": "GBP"
  }
}
```

Test:

```
curl -i https://<api-id>.execute-api.<region>.amazonaws.com/webhook \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{"id":"evt_123456","type":"order.created","created_at":"2026-02-28T16:40:00Z","data":{"order_id":"ORD-98765","amount":129.99,"currency":"GBP"}}'
```

