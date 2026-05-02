Oceans Across — DevOps Assignment
=================================

Professional DevOps deliverable: secure multi-tenant payroll infrastructure on AWS using Terraform, Docker, and GitHub Actions.

Project layout

- `terraform/` — Terraform modules and environment overlays
- `app/` — Minimal Flask service used for deployment demonstration
- `.github/workflows/deploy.yml` — CI/CD pipeline
- `docs/` — tenancy, security, and runbook docs

Quick start (development environment)

1. Install Terraform 1.4+, AWS CLI, and Docker.
2. Configure AWS credentials in your environment or via AWS SSO.
3. Review `terraform/environments/dev/terraform.tfvars` and adjust values.

Example:

```bash
cd terraform/environments/dev
terraform init
terraform apply -var-file=terraform.tfvars
```

CI/CD

The GitHub Actions workflow builds the Docker image, runs a basic test, and deploys to EC2 using SSM. Secrets are injected via GitHub Secrets.

Monitoring & Security

CloudWatch alarms for EC2 and RDS are recommended; SNS used for alerts. Secrets should be stored in AWS Secrets Manager or SSM Parameter Store.

For full details see files in `docs/`.

UK Compliance Considerations
===========================

1) AWS-native controls to stay compliant with UK GDPR when storing employee PII and bank data:
- **Encryption at rest & in transit:** use AWS KMS customer-managed CMKs (in-region), enable RDS/Aurora encryption, EBS encryption, and S3 server-side encryption (SSE-KMS). Enforce TLS for all in-transit data.
- **Access control & auditing:** enforce least-privilege IAM roles, enable AWS CloudTrail with multi-region trails (logs stored in-region), enable AWS Config and IAM Access Analyzer, and require MFA for privileged accounts.
- **Data discovery & monitoring:** use Amazon CloudWatch Alarms + SNS for alerting.
- **Secret and key management:** store secrets in AWS Secrets Manager or SSM Parameter Store and rotate regularly.
- **Network controls:** use VPC, private subnets, VPC endpoints for S3/SSM, and restrict public access via Security Groups and NACLs.
- **Backup & retention controls:** use AWS Backup with controlled retention and lifecycle policies; tag PII-bearing resources so backups are discoverable and governed.

2) Ensuring data residency within the UK/EU region:
- **Deploy and store data only in UK/EU regions** (e.g., eu-west-2 for London). Set the Terraform AWS provider/region accordingly for PII resources.
- **Prevent cross-region creation:** enforce Service Control Policies (SCPs) in AWS Organizations and Config rules to deny resource creation outside allowed regions.
- **Region-aware services & replication:** disable or carefully control cross-region replication (S3 replication, RDS read replicas); if replication is necessary, document lawful basis and controls.

3) Handling permanent deletion (Right to Erasure):
- **Design for deletability:** isolate PII into dedicated datasets (separate S3 buckets, DB schemas, or RDS instances) and tag data for easy discovery.
- **Deletion workflow:** automate deletion via an auditable process that removes data from primary stores, then deletes all S3 object versions, removes RDS snapshots, and deletes related backups (AWS Backup vaults/snapshots) where policy permits.
- **Address immutable stores:** for long-term/archival stores (Glacier, immutable backups), ensure retention policies allow timely removal or use cryptographic erasure by rotating and then deleting KMS key material where legally and operationally appropriate.
- **Proof & logging:** record deletion actions in CloudTrail and produce a deletion report for the data subject; use Config and tagging to verify no remaining copies.
- **Operational governance:** pair deletion automation with a documented policy, Data Protection Impact Assessment (DPIA), and periodic audits to ensure compliance.

For more detail, see `docs/security.md` and `docs/tenancy.md` for operational controls and tenancy separation patterns.

