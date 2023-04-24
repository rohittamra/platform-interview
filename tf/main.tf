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
  vault_addr        = "http://vault_${var.environment}:8200"
  environment_names = ["development", "staging", "production"]
  images = {
    account   = "form3tech-oss/platformtest-account",
    gateway   = "form3tech-oss/platformtest-gateway",
    payment   = "form3tech-oss/platformtest-payment",
    #frontend  = "docker.io/nginx:latest",
    #frontend2 = "docker.io/nginx:1.22.0-alpine",
    #frontend   = ${var.environment} == "production" ? "docker.io/nginx:1.22.0-alpine" : "docker.io/nginx:latest"
  }
}

variable "environment" {
  type        = string
  description = "The environment to deploy the microservices (development, staging, production)"
  default = "development"

}

resource "docker_network" "vagrant" {
  name = "vagrant_${var.environment}"
}

resource "docker_container" "microservice" {
  for_each = {
    for name, image in local.images : name => image
    if name != "frontend2"
  }

  image = each.value
  name  = "${each.key}_${var.environment}"

  env = [
    "VAULT_ADDR=${local.vault_addr}",
    "VAULT_USERNAME=${each.key}-${var.environment}",
    "VAULT_PASSWORD=123-${each.key}-${var.environment}",
    "ENVIRONMENT=${var.environment}"
  ]

  networks_advanced {
    name = docker_network.vagrant.name
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "docker_container" "frontend" {
  image =  var.environment == "production" ? "docker.io/nginx:1.22.0-alpine" : "docker.io/nginx:latest"
  name  = "frontend_${var.environment}"

  ports {
    internal = 80
    external = var.environment == "production" ? 4081 : 4080
  }

  networks_advanced {
    name = docker_network.vagrant.name
  }

  lifecycle {
    ignore_changes = all
  }
}

