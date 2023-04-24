Summary:

•	Removed the explicit version requirement for the "vault" provider since it's already specified in the provider blocks.
•	Consolidated the "vault" provider blocks for "dev" and "prod" into one provider block each, using aliases to differentiate between them.
•	Used a map to define the resource instances for the "vault_audit" and "vault_auth_backend" resources, with the provider specified as a value in the map.
•	Used the "for_each" meta-argument to create multiple instances of the "vault_audit" and "vault_auth_backend" resources, one for each provider instance.
•       Created a variable called enviornemt which accepts 3 values "staging", "development" (default) and "production. Acoording to this the account gateway and payment images are picked with the name appended with the env chosen
•       For frontend image if its a production env then only nginx apline image will be selected otherwise nginx latest will be selected	




Things didnt work:
Vagrant didnt worked.Below is the error. Hence I created the run.sh according to my needs installing prerequiste like docker, docker-compose, git, terraform using apt-get install command in ubuntu box.

root@testvm1:/home/azureuser/platform-interview# vagrant up
Bringing machine 'interview' up with 'virtualbox' provider...
==> interview: Checking if box 'ubuntu/bionic64' version '20230414.0.0' is up to date...
==> interview: Clearing any previously set forwarded ports...
==> interview: Clearing any previously set network interfaces...
==> interview: Preparing network interfaces based on configuration...
    interview: Adapter 1: nat
==> interview: Forwarding ports...
    interview: 22 (guest) => 2222 (host) (adapter 1)
==> interview: Running 'pre-boot' VM customizations...
==> interview: Booting VM...
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.
Command: ["startvm", "4645b420-edde-4579-94df-1c70068900f2", "--type", "headless"]
Stderr: VBoxManage: error: VT-x is not available (VERR_VMX_NO_VMX)
VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component ConsoleWrap, interface IConsole




Test Cases:

#########################################
####   when running in  production ######
#########################################

terraform apply -var environment="production"

root@testvm1:/home/azureuser/platform-interview/tf# docker ps
CONTAINER ID   IMAGE                                COMMAND                  CREATED         STATUS         PORTS                                       NAMES
c2b236db7fbc   nginx:1.22.0-alpine                  "/docker-entrypoint.…"   7 seconds ago   Up 5 seconds   0.0.0.0:4081->80/tcp                        frontend_production
a621fed0f9fe   form3tech-oss/platformtest-account   "/go/bin/account"        7 seconds ago   Up 5 seconds                                               account_production
e3bc1b640b8b   vault:1.8.3                          "docker-entrypoint.s…"   8 hours ago     Up 8 hours     0.0.0.0:8201->8200/tcp, :::8201->8200/tcp   platform-interview-vault-development-1
101b3f758bb2   vault:1.8.3                          "docker-entrypoint.s…"   8 hours ago     Up 8 hours     0.0.0.0:8301->8200/tcp, :::8301->8200/tcp   platform-interview-vault-production-1


#########################################
####   when running in  staging    ######
#### TASK 2: add a variable staging #####
#########################################

terraform apply -var environment="staging"

root@testvm1:/home/azureuser/platform-interview/tf# docker ps
CONTAINER ID   IMAGE                                COMMAND                  CREATED          STATUS          PORTS                                       NAMES
8289ba893d35   nginx:latest                         "/docker-entrypoint.…"   14 seconds ago   Up 12 seconds   0.0.0.0:4080->80/tcp                        frontend_staging
e5007cfd568a   form3tech-oss/platformtest-account   "/go/bin/account"        14 seconds ago   Up 13 seconds                                               account_staging
e3bc1b640b8b   vault:1.8.3                          "docker-entrypoint.s…"   8 hours ago      Up 8 hours      0.0.0.0:8201->8200/tcp, :::8201->8200/tcp   platform-interview-vault-development-1
101b3f758bb2   vault:1.8.3                          "docker-entrypoint.s…"   8 hours ago      Up 8 hours      0.0.0.0:8301->8200/tcp, :::8301->8200/tcp   platform-interview-vault-production-1


root@testvm1:/home/azureuser/platform-interview# sh ./run.sh
Installing docker-compose
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 23.4M  100 23.4M    0     0  41.0M      0 --:--:-- --:--:-- --:--:-- 41.0M
Installing terraform onto machine...
Hit:1 http://azure.archive.ubuntu.com/ubuntu focal InRelease
Hit:2 http://azure.archive.ubuntu.com/ubuntu focal-updates InRelease
Hit:3 http://azure.archive.ubuntu.com/ubuntu focal-backports InRelease
Hit:4 http://azure.archive.ubuntu.com/ubuntu focal-security InRelease
Hit:5 http://download.virtualbox.org/virtualbox/debian xenial InRelease
Hit:6 https://apt.releases.hashicorp.com focal InRelease
Reading package lists... Done
Reading package lists... Done
Building dependency tree
Reading state information... Done
unzip is already the newest version (6.0-25ubuntu1.1).
jq is already the newest version (1.6-1ubuntu0.20.04.1).
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Building Docker images...
Sending build context to Docker daemon  4.769MB
Step 1/7 : FROM golang:alpine AS builder
 ---> 818ca3531f99
Step 2/7 : WORKDIR $GOPATH/src/form3tech/account/
 ---> Using cache
 ---> eeb0f31eef63
Step 3/7 : COPY . .
 ---> Using cache
 ---> ddecc4548e11
Step 4/7 : RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /go/bin/account
 ---> Using cache
 ---> 0ee8c83fd655
Step 5/7 : FROM scratch
 --->
Step 6/7 : COPY --from=builder /go/bin/account /go/bin/account
 ---> Using cache
 ---> c1c3baa021f7
Step 7/7 : ENTRYPOINT ["/go/bin/account"]
 ---> Using cache
 ---> a2ec026a6568
Successfully built a2ec026a6568
Successfully tagged form3tech-oss/platformtest-account:latest
Sending build context to Docker daemon  4.769MB
Step 1/7 : FROM golang:alpine AS builder
 ---> 818ca3531f99
Step 2/7 : WORKDIR $GOPATH/src/form3tech/gateway/
 ---> Using cache
 ---> 2901a77f8d2b
Step 3/7 : COPY . .
 ---> Using cache
 ---> 93f3d9d81aea
Step 4/7 : RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /go/bin/gateway
 ---> Using cache
 ---> d79ff41f59ed
Step 5/7 : FROM scratch
 --->
Step 6/7 : COPY --from=builder /go/bin/gateway /go/bin/gateway
 ---> Using cache
 ---> b2bbb29d9489
Step 7/7 : ENTRYPOINT ["/go/bin/gateway"]
 ---> Using cache
 ---> aa1b91d69906
Successfully built aa1b91d69906
Successfully tagged form3tech-oss/platformtest-gateway:latest
Sending build context to Docker daemon  4.769MB
Step 1/7 : FROM golang:alpine AS builder
 ---> 818ca3531f99
Step 2/7 : WORKDIR $GOPATH/src/form3tech/payment/
 ---> Using cache
 ---> b2c779e8701b
Step 3/7 : COPY . .
 ---> Using cache
 ---> 0b9070ee5a0d
Step 4/7 : RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /go/bin/payment
 ---> Using cache
 ---> 2c069fa99d95
Step 5/7 : FROM scratch
 --->
Step 6/7 : COPY --from=builder /go/bin/payment /go/bin/payment
 ---> Using cache
 ---> 07205cbd9ccf
Step 7/7 : ENTRYPOINT ["/go/bin/payment"]
 ---> Using cache
 ---> 482ecc8ff3fb
Successfully built 482ecc8ff3fb
Successfully tagged form3tech-oss/platformtest-payment:latest
[+] Running 2/0
 ⠿ Container platform-interview-vault-production-1   Running                             0.0s
 ⠿ Container platform-interview-vault-development-1  Running                             0.0s
Applying terraform script

Initializing the backend...

Initializing provider plugins...
- Finding kreuzwerker/docker versions matching "2.15.0"...
- Finding hashicorp/vault versions matching "3.0.1"...
- Using previously-installed hashicorp/vault v3.0.1
- Using previously-installed kreuzwerker/docker v2.15.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # docker_container.frontend will be created
  + resource "docker_container" "frontend" {
      + attach           = false
      + bridge           = (known after apply)
      + command          = (known after apply)
      + container_logs   = (known after apply)
      + entrypoint       = (known after apply)
      + env              = (known after apply)
      + exit_code        = (known after apply)
      + gateway          = (known after apply)
      + hostname         = (known after apply)
      + id               = (known after apply)
      + image            = "docker.io/nginx:latest"
      + init             = (known after apply)
      + ip_address       = (known after apply)
      + ip_prefix_length = (known after apply)
      + ipc_mode         = (known after apply)
      + log_driver       = "json-file"
      + logs             = false
      + must_run         = true
      + name             = "frontend_development"
      + network_data     = (known after apply)
      + read_only        = false
      + remove_volumes   = true
      + restart          = "no"
      + rm               = false
      + security_opts    = (known after apply)
      + shm_size         = (known after apply)
      + start            = true
      + stdin_open       = false
      + tty              = false

      + networks_advanced {
          + aliases = []
          + name    = "vagrant_development"
        }

      + ports {
          + external = 4080
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }
    }

  # docker_container.microservice["account"] will be created
  + resource "docker_container" "microservice" {
      + attach           = false
      + bridge           = (known after apply)
      + command          = (known after apply)
      + container_logs   = (known after apply)
      + entrypoint       = (known after apply)
      + env              = [
          + "ENVIRONMENT=development",
          + "VAULT_ADDR=http://vault_development:8200",
          + "VAULT_PASSWORD=123-account-development",
          + "VAULT_USERNAME=account-development",
        ]
      + exit_code        = (known after apply)
      + gateway          = (known after apply)
      + hostname         = (known after apply)
      + id               = (known after apply)
      + image            = "form3tech-oss/platformtest-account"
      + init             = (known after apply)
      + ip_address       = (known after apply)
      + ip_prefix_length = (known after apply)
      + ipc_mode         = (known after apply)
      + log_driver       = "json-file"
      + logs             = false
      + must_run         = true
      + name             = "account_development"
      + network_data     = (known after apply)
      + read_only        = false
      + remove_volumes   = true
      + restart          = "no"
      + rm               = false
      + security_opts    = (known after apply)
      + shm_size         = (known after apply)
      + start            = true
      + stdin_open       = false
      + tty              = false

      + networks_advanced {
          + aliases = []
          + name    = "vagrant_development"
        }
    }

  # docker_container.microservice["gateway"] will be created
  + resource "docker_container" "microservice" {
      + attach           = false
      + bridge           = (known after apply)
      + command          = (known after apply)
      + container_logs   = (known after apply)
      + entrypoint       = (known after apply)
      + env              = [
          + "ENVIRONMENT=development",
          + "VAULT_ADDR=http://vault_development:8200",
          + "VAULT_PASSWORD=123-gateway-development",
          + "VAULT_USERNAME=gateway-development",
        ]
      + exit_code        = (known after apply)
      + gateway          = (known after apply)
      + hostname         = (known after apply)
      + id               = (known after apply)
      + image            = "form3tech-oss/platformtest-gateway"
      + init             = (known after apply)
      + ip_address       = (known after apply)
      + ip_prefix_length = (known after apply)
      + ipc_mode         = (known after apply)
      + log_driver       = "json-file"
      + logs             = false
      + must_run         = true
      + name             = "gateway_development"
      + network_data     = (known after apply)
      + read_only        = false
      + remove_volumes   = true
      + restart          = "no"
      + rm               = false
      + security_opts    = (known after apply)
      + shm_size         = (known after apply)
      + start            = true
      + stdin_open       = false
      + tty              = false

      + networks_advanced {
          + aliases = []
          + name    = "vagrant_development"
        }
    }

  # docker_container.microservice["payment"] will be created
  + resource "docker_container" "microservice" {
      + attach           = false
      + bridge           = (known after apply)
      + command          = (known after apply)
      + container_logs   = (known after apply)
      + entrypoint       = (known after apply)
      + env              = [
          + "ENVIRONMENT=development",
          + "VAULT_ADDR=http://vault_development:8200",
          + "VAULT_PASSWORD=123-payment-development",
          + "VAULT_USERNAME=payment-development",
        ]
      + exit_code        = (known after apply)
      + gateway          = (known after apply)
      + hostname         = (known after apply)
      + id               = (known after apply)
      + image            = "form3tech-oss/platformtest-payment"
      + init             = (known after apply)
      + ip_address       = (known after apply)
      + ip_prefix_length = (known after apply)
      + ipc_mode         = (known after apply)
      + log_driver       = "json-file"
      + logs             = false
      + must_run         = true
      + name             = "payment_development"
      + network_data     = (known after apply)
      + read_only        = false
      + remove_volumes   = true
      + restart          = "no"
      + rm               = false
      + security_opts    = (known after apply)
      + shm_size         = (known after apply)
      + start            = true
      + stdin_open       = false
      + tty              = false

      + networks_advanced {
          + aliases = []
          + name    = "vagrant_development"
        }
    }

  # docker_network.vagrant will be created
  + resource "docker_network" "vagrant" {
      + driver      = (known after apply)
      + id          = (known after apply)
      + internal    = (known after apply)
      + ipam_driver = "default"
      + name        = "vagrant_development"
      + options     = (known after apply)
      + scope       = (known after apply)
    }

  # vault_audit.audit_dev will be created
  + resource "vault_audit" "audit_dev" {
      + id      = (known after apply)
      + options = {
          + "file_path" = "/vault/logs/audit"
        }
      + path    = (known after apply)
      + type    = "file"
    }

  # vault_audit.audit_prod will be created
  + resource "vault_audit" "audit_prod" {
      + id      = (known after apply)
      + options = {
          + "file_path" = "/vault/logs/audit"
        }
      + path    = (known after apply)
      + type    = "file"
    }

  # vault_auth_backend.userpass_dev will be created
  + resource "vault_auth_backend" "userpass_dev" {
      + accessor = (known after apply)
      + id       = (known after apply)
      + path     = (known after apply)
      + tune     = (known after apply)
      + type     = "userpass"
    }

  # vault_auth_backend.userpass_prod will be created
  + resource "vault_auth_backend" "userpass_prod" {
      + accessor = (known after apply)
      + id       = (known after apply)
      + path     = (known after apply)
      + tune     = (known after apply)
      + type     = "userpass"
    }

  # vault_generic_endpoint.account_development will be created
  + resource "vault_generic_endpoint" "account_development" {
      + data_json            = (sensitive value)
      + disable_delete       = false
      + disable_read         = false
      + id                   = (known after apply)
      + ignore_absent_fields = true
      + path                 = "auth/userpass/users/account-development"
      + write_data           = (known after apply)
      + write_data_json      = (known after apply)
    }

  # vault_generic_endpoint.gateway_development will be created
  + resource "vault_generic_endpoint" "gateway_development" {
      + data_json            = (sensitive value)
      + disable_delete       = false
      + disable_read         = false
      + id                   = (known after apply)
      + ignore_absent_fields = true
      + path                 = "auth/userpass/users/gateway-development"
      + write_data           = (known after apply)
      + write_data_json      = (known after apply)
    }

  # vault_generic_endpoint.payment_development will be created
  + resource "vault_generic_endpoint" "payment_development" {
      + data_json            = (sensitive value)
      + disable_delete       = false
      + disable_read         = false
      + id                   = (known after apply)
      + ignore_absent_fields = true
      + path                 = "auth/userpass/users/payment-development"
      + write_data           = (known after apply)
      + write_data_json      = (known after apply)
    }

  # vault_generic_secret.account_development will be created
  + resource "vault_generic_secret" "account_development" {
      + data         = (sensitive value)
      + data_json    = (sensitive value)
      + disable_read = false
      + id           = (known after apply)
      + path         = "secret/development/account"
    }

  # vault_generic_secret.account_production will be created
  + resource "vault_generic_secret" "account_production" {
      + data         = (sensitive value)
      + data_json    = (sensitive value)
      + disable_read = false
      + id           = (known after apply)
      + path         = "secret/production/account"
    }

  # vault_generic_secret.gateway_development will be created
  + resource "vault_generic_secret" "gateway_development" {
      + data         = (sensitive value)
      + data_json    = (sensitive value)
      + disable_read = false
      + id           = (known after apply)
      + path         = "secret/development/gateway"
    }

  # vault_generic_secret.payment_development will be created
  + resource "vault_generic_secret" "payment_development" {
      + data         = (sensitive value)
      + data_json    = (sensitive value)
      + disable_read = false
      + id           = (known after apply)
      + path         = "secret/development/payment"
    }

  # vault_policy.account_development will be created
  + resource "vault_policy" "account_development" {
      + id     = (known after apply)
      + name   = "account-development"
      + policy = <<-EOT
            path "secret/data/development/account" {
              capabilities = ["list", "read"]
            }
        EOT
    }

  # vault_policy.account_production will be created
  + resource "vault_policy" "account_production" {
      + id     = (known after apply)
      + name   = "account-production"
      + policy = <<-EOT
            path "secret/data/production/account" {
              capabilities = ["list", "read"]
            }
        EOT
    }

  # vault_policy.gateway_development will be created
  + resource "vault_policy" "gateway_development" {
      + id     = (known after apply)
      + name   = "gateway-development"
      + policy = <<-EOT
            path "secret/data/development/gateway" {
              capabilities = ["list", "read"]
            }
        EOT
    }

  # vault_policy.payment_development will be created
  + resource "vault_policy" "payment_development" {
      + id     = (known after apply)
      + name   = "payment-development"
      + policy = <<-EOT
            path "secret/data/development/payment" {
              capabilities = ["list", "read"]
            }
        EOT
    }

Plan: 20 to add, 0 to change, 0 to destroy.
vault_auth_backend.userpass_dev: Creating...
vault_audit.audit_dev: Creating...
vault_auth_backend.userpass_dev: Creation complete after 0s [id=userpass]
vault_generic_secret.payment_development: Creating...
vault_policy.account_production: Creating...
vault_generic_secret.gateway_development: Creating...
vault_policy.account_development: Creating...
vault_policy.payment_development: Creating...
vault_generic_secret.account_production: Creating...
vault_policy.gateway_development: Creating...
vault_audit.audit_dev: Creation complete after 0s [id=file]
vault_auth_backend.userpass_prod: Creating...
vault_auth_backend.userpass_prod: Creation complete after 0s [id=userpass]
vault_generic_secret.account_development: Creating...
vault_generic_endpoint.payment_development: Creating...
vault_policy.gateway_development: Creation complete after 0s [id=gateway-development]
vault_generic_secret.payment_development: Creation complete after 0s [id=secret/development/payment]
vault_policy.account_production: Creation complete after 0s [id=account-production]
vault_policy.account_development: Creation complete after 0s [id=account-development]
vault_generic_endpoint.account_development: Creating...
vault_audit.audit_prod: Creating...
vault_generic_endpoint.gateway_development: Creating...
vault_policy.payment_development: Creation complete after 0s [id=payment-development]
vault_audit.audit_prod: Creation complete after 0s [id=file]
vault_generic_secret.account_production: Creation complete after 0s [id=secret/production/account]
docker_network.vagrant: Creating...
vault_generic_secret.gateway_development: Creation complete after 0s [id=secret/development/gateway]
vault_generic_secret.account_development: Creation complete after 0s [id=secret/development/account]
vault_generic_endpoint.account_development: Creation complete after 0s [id=auth/userpass/users/account-development]
vault_generic_endpoint.payment_development: Creation complete after 0s [id=auth/userpass/users/payment-development]
vault_generic_endpoint.gateway_development: Creation complete after 0s [id=auth/userpass/users/gateway-development]
docker_network.vagrant: Creation complete after 2s [id=91dab2c262cd5b349484c5da91c1d13ad3a858be1a199f5928c77ba29c5bd0b2]
docker_container.microservice["gateway"]: Creating...
docker_container.microservice["payment"]: Creating...
docker_container.frontend: Creating...
docker_container.microservice["account"]: Creating...
docker_container.microservice["gateway"]: Creation complete after 2s [id=99bb68947091d992978d750a2badfb0a49c4a8c5105f79a65bdae97c9ccd634e]
docker_container.microservice["account"]: Creation complete after 2s [id=ed94368b1a67d742b8f5e6dfca223610a3e8c4cdac4f862840f882fb35cb8736]
docker_container.microservice["payment"]: Creation complete after 2s [id=9b37a757d0e0a6db9e34fe0a88a2ad270a27fd50159c37e08260cbb6a620bada]
docker_container.frontend: Creation complete after 2s [id=e26a3c7ced854747a860e7ddb909363c0f042379d34b5d42a58f4732b70f1c44]

Apply complete! Resources: 20 added, 0 changed, 0 destroyed.

#########################################
###By default it will take development###
#########################################

root@testvm1:/home/azureuser/platform-interview# docker ps
CONTAINER ID   IMAGE                                COMMAND                  CREATED          STATUS          PORTS                                       NAMES
e26a3c7ced85   nginx:latest                         "/docker-entrypoint.…"   12 seconds ago   Up 10 seconds   0.0.0.0:4080->80/tcp                        frontend_development
ed94368b1a67   form3tech-oss/platformtest-account   "/go/bin/account"        12 seconds ago   Up 10 seconds                                               account_development
e3bc1b640b8b   vault:1.8.3                          "docker-entrypoint.s…"   8 hours ago      Up 8 hours      0.0.0.0:8201->8200/tcp, :::8201->8200/tcp   platform-interview-vault-development-1
101b3f758bb2   vault:1.8.3                          "docker-entrypoint.s…"   8 hours ago      Up 8 hours      0.0.0.0:8301->8200/tcp, :::8301->8200/tcp   platform-interview-vault-production-1
