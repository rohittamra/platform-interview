terraform {
  required_version = ">= 1.0.7"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }

    vault = {
      version = "3.0.1"
    }
  }
}


provider "vault" {
  address = "http://localhost:8201"
  token   = "f23612cf-824d-4206-9e94-e31a6dc8ee8d"
}

provider "vault" {
  alias   = "vault_dev"
  address = "http://localhost:8201"
  token   = "f23612cf-824d-4206-9e94-e31a6dc8ee8d"
}

provider "vault" {
  alias   = "vault_prod"
  address = "http://localhost:8301"
  token   = "083672fc-4471-4ec4-9b59-a285e463a973"
}


resource "vault_audit" "audit_dev" {
  type     = "file"
  provider = vault.vault_dev

  options = {
    file_path = "/vault/logs/audit"
  }
}

resource "vault_audit" "audit_prod" {
  type     = "file"
  provider = vault.vault_prod

  options = {
    file_path = "/vault/logs/audit"
  }
}

resource "vault_auth_backend" "userpass_dev" {
  type     = "userpass"
  provider = vault.vault_dev
}

resource "vault_auth_backend" "userpass_prod" {
  type     = "userpass"
  provider = vault.vault_prod
}

#provider "vault" {
#  address = "http://vault.example.com:8200"
#}

resource "vault_generic_secret" "account_development" {
  path     = "secret/development/account"
  data_json = jsonencode({
    db_user     = "account"
    db_password = "965d3c27-9e20-4d41-91c9-61e6631870e7"
  })
}

resource "vault_policy" "account_development" {
  name   = "account-development"
  policy = <<-EOT
    path "secret/data/development/account" {
      capabilities = ["list", "read"]
    }
  EOT
}

resource "vault_generic_endpoint" "account_development" {
  path                 = "auth/userpass/users/account-development"
  depends_on           = [vault_auth_backend.userpass_dev]
  ignore_absent_fields = true
  data_json            = jsonencode({
    policies = ["account-development"]
    password = "123-account-development"
  })
}

resource "vault_generic_secret" "gateway_development" {
  path     = "secret/development/gateway"
  data_json = jsonencode({
    db_user     = "gateway"
    db_password = "10350819-4802-47ac-9476-6fa781e35cfd"
  })
}

resource "vault_policy" "gateway_development" {
  name   = "gateway-development"
  policy = <<-EOT
    path "secret/data/development/gateway" {
      capabilities = ["list", "read"]
    }
  EOT
}

resource "vault_generic_endpoint" "gateway_development" {
  path                 = "auth/userpass/users/gateway-development"
  depends_on           = [vault_auth_backend.userpass_dev]
  ignore_absent_fields = true
  data_json            = jsonencode({
    policies = ["gateway-development"]
    password = "123-gateway-development"
  })
}

resource "vault_generic_secret" "payment_development" {
  path     = "secret/development/payment"
  data_json = jsonencode({
    db_user     = "payment"
    db_password = "a63e8938-6d49-49ea-905d-e03a683059e7"
  })
}

resource "vault_policy" "payment_development" {
  name   = "payment-development"
  policy = <<-EOT
    path "secret/data/development/payment" {
      capabilities = ["list", "read"]
    }
  EOT
}

resource "vault_generic_endpoint" "payment_development" {
  path                 = "auth/userpass/users/payment-development"
  depends_on           = [vault_auth_backend.userpass_dev]
  ignore_absent_fields = true
  data_json            = jsonencode({
    policies = ["payment-development"]
    password = "123-payment-development"
  })
}

resource "vault_generic_secret" "account_production" {
  path     = "secret/production/account"
  data_json = jsonencode({
    db_user     = "account"
    db_password = "396e73e7-34d5-4b0a-ae1b-b128aa7f9977"
  })
}

resource "vault_policy" "account_production" {
  name   = "account-production"
  policy = <<-EOT
    path "secret/data/production/account" {
      capabilities = ["list", "read"]
    }
  EOT
}


variable "environment" {
  default = "development"
}

variable "vault_address" {
  default = "http://vault-development:8200"
}

variable "network_name" {
  default = "vagrant_development"
}

variable "nginx_image" {
  default = "docker.io/nginx:latest"
}

variable "alpine_image" {
  default = "form3tech-oss/platformtest-%s"
}

variable "vault_credentials" {
  default = {
    "account" = "123-account-%s"
    "gateway" = "123-gateway-%s"
    "payment" = "123-payment-%s"
  }
}

locals {
  container_names = {
    "account"   = "account_${var.environment}"
    "gateway"   = "gateway_${var.environment}"
    "payment"   = "payment_${var.environment}"
    "frontend"  = "frontend_${var.environment}"
  }

  container_images = {
    "account"   = format(var.alpine_image, "account")
    "gateway"   = format(var.alpine_image, "gateway")
    "payment"   = format(var.alpine_image, "payment")
    "frontend"  = var.nginx_image
  }

  container_ports = {
    "account"   = null
    "gateway"   = null
    "payment"   = null
    "frontend"  = {
      internal = 80
      external = var.environment == "production" ? 4081 : 4080
    }
  }

  container_env_vars = {
    "account"   = {
      VAULT_ADDR      = var.vault_address
      VAULT_USERNAME  = format(var.vault_credentials["account"], var.environment)
      VAULT_PASSWORD  = format(var.vault_credentials["account"], var.environment)
      ENVIRONMENT     = var.environment
    }
    "gateway"   = {
      VAULT_ADDR      = var.vault_address
      VAULT_USERNAME  = format(var.vault_credentials["gateway"], var.environment)
      VAULT_PASSWORD  = format(var.vault_credentials["gateway"], var.environment)
      ENVIRONMENT     = var.environment
    }
    "payment"   = {
      VAULT_ADDR      = var.vault_address
      VAULT_USERNAME  = format(var.vault_credentials["payment"], var.environment)
      VAULT_PASSWORD  = format(var.vault_credentials["payment"], var.environment)
      ENVIRONMENT     = var.environment
    }
    "frontend"  = {
      ENVIRONMENT     = var.environment
    }
  }
}

resource "docker_container" "containers" {
  count = length(local.container_names)

  image = local.container_images[count.index]
  name  = local.container_names[count.index]

  ports = local.container_ports[count.index] != null ? [{    internal = local.container_ports[count.index]["internal"]
    external = local.container_ports[count.index]["external"]
  }] : []

  env = toset([
    for k, v in local.container_env_vars[count.index] : "${k}=${v}"
  ])

  networks_advanced {
    name = var.network_name
  }

  lifecycle {
    ignore_changes = all
  }
}

