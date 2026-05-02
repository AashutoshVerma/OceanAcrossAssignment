Security Overview
=================

IAM Role separation

- Each service and tenant class is given a narrowly scoped IAM role.
- `company-role`, `bureau-role`, `employee-role` only have S3 access to their prefix.
- EC2 instances that run services use instance profiles mapped to service roles.

Secrets management

- Store DB credentials and API keys in AWS Secrets Manager or SSM Parameter Store (SecureString).
- Terraform should not hardcode secrets. Use remote state and pass secrets via CI secrets or native secret stores.

Encryption

- S3: Server-side encryption with KMS (customer managed key created in module). Versioning enabled.
- RDS: Storage encrypted (`storage_encrypted = true`). Use KMS with proper key rotation and access controls.
- TLS: All client-service communications should use HTTPS/TLS; enable TLS at ingress (ALB) and enforce TLS on S3 bucket policy.

Network security

- RDS is placed in private subnets and `publicly_accessible = false`.
- EC2 instances are placed in private/public subnets depending on role; security groups restrict to SSH from admin CIDR and HTTP to necessary sources.
- Use NAT Gateway for outbound connectivity from private subnets.

Preventing cross-tenant access even if app fails

- Principle of least privilege: IAM policies restrict S3 prefixes; DB users have restricted privileges per-schema.
- Defense-in-depth: even if application mistakenly issues broad S3 calls, the IAM policies will restrict operations to allowed prefixes.
- Monitoring: CloudWatch logs and alarms for anomalous access patterns; alerting via SNS.
