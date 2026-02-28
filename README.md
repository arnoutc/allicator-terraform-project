
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

ENV=dev make destroy

# Terraform Template Repository

This repository contains reusable Terraform configurations for infrastructure as code.
