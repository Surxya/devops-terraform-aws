# Modular AWS Infrastructure & Containerized App Behind Nginx (Terraform)

Automated, reproducible AWS infrastructure provisioned with modular Terraform, remote S3 state locking, and Docker Compose behind an Nginx reverse proxy.

## Goal & Architecture

Provision an isolated VPC, hardened security groups, an EC2 compute instance (`t3.micro`), and CloudWatch CPU alerting using reusable Terraform modules. On boot, `cloud-init` configures 1 GB swap memory, installs Docker Engine, and launches the Jakarta EE application container behind an Nginx reverse proxy.

```text
+-------------------------------------------------------------------------+
| AWS Cloud (ap-south-1 / Mumbai)                                         |
|  +-------------------------------------------------------------------+  |
|  | VPC (10.0.0.0/16) -> Public Subnet (10.0.1.0/24) -> IGW           |  |
|  |  +-------------------------------------------------------------+  |  |
|  |  | EC2 (t3.micro) + SG (80, 22)                                |  |  |
|  |  | Internet :80 -> [ Nginx 1.27 ] -> [ Tomcat App :8080 ]      |  |  |
|  |  +-------------------------------------------------------------+  |  |
|  +-------------------------------------------------------------------+  |
|  [ S3 Remote State + Locking ]      [ CloudWatch CPU Alarm -> SNS ]     |
+-------------------------------------------------------------------------+
```

## Repository Structure

```text
devops-terraform-aws/
├── app/                   # Dockerfile packaging devops-demo.war
├── bootstrap/             # Remote S3 state bucket configuration
├── docs/screenshots/      # Verification & AWS Console screenshots
├── envs/dev/              # Dev environment wiring, variables, user_data
├── modules/               # Reusable vpc, security, and ec2 modules
└── scripts/               # rebuild.sh and smoke_test.sh automation
```

## How to Run

1. **Bootstrap Remote State:** `cd bootstrap && terraform init && terraform apply`
2. **Provision Dev Environment:** `cd ../envs/dev && terraform init && terraform apply`
3. **Run Smoke Tests:** `../../scripts/smoke_test.sh http://<PUBLIC_IP>`
4. **Teardown Infrastructure:** `terraform destroy`

## Security Scan (Trivy)

Ran Aquasec Trivy (`trivy config /src`) across all Terraform modules and Dockerfiles. Accepted findings for AWS Free-Tier demo:

| Finding ID | Resource | Accepted Rationale |
| :--- | :--- | :--- |
| `AWS-0164` / `AWS-0104` | Public Subnet IP & `0.0.0.0/0` Egress | Required for public HTTP (`80`) and package pulls without NAT Gateway ($32+/mo). |
| `AWS-0178` / `AWS-0089` | VPC Flow Logs & S3 Access Logging | Omitted to avoid CloudWatch ingestion and secondary storage charges. |
| `AWS-0132` / `AWS-0095` | S3 CMK & SNS KMS Encryption | Used free default `AES256` (`SSE-S3`) instead of paid KMS CMKs ($1/mo). |
| `DS-0002` / `DS-0026` | Dockerfile `USER` & `HEALTHCHECK` | Health checked via `/nginx-health` and `/health`; non-root user queued for Project 3. |

## Verification & Screenshots

* **Live App & Proxy:** ![App in Browser](docs/screenshots/app-in-browser.png)
* **EC2 Instance:** ![EC2 Instance](docs/screenshots/ec2-running-instance.png)
* **S3 Remote State:** ![S3 State](docs/screenshots/s3-state-bucket.png)
* **CloudWatch & SNS Alerting:** ![CloudWatch Alarm](docs/screenshots/cloudwatch-sns-alarm.png)
* **Trivy IaC Security Scan:** ![Trivy Scan](docs/screenshots/trivy-security-scan.png)

## Cost Notes & Cleanup

* Uses `t3.micro`, 8 GB `gp3`, single-AZ public subnet (no NAT Gateway), and native S3 locking (no DynamoDB).
* Always run `terraform destroy` inside `envs/dev` after testing while retaining the S3 state bucket.

## Lessons Learned

* **Swap Memory for Java Containers:** Adding a 1 GB swapfile in `user_data` prevents OOM stalls during image extraction on 1 GB RAM `t3.micro` instances.
* **In-Place vs. Replacement:** Tag changes update in-place (`~`), whereas `user_data` updates replace the instance cleanly (`-/+`).
