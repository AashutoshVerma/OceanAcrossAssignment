Incident Runbook: RDS accidentally becomes publicly accessible
=============================================================

Detection

- CloudWatch metric `PubliclyAccessible` is not directly exposed; detect via Config rule `rds-instance-publicly-accessible` or AWS Config managed rule.
- Alert: SNS topic triggered when AWS Config or Terraform drift detection flags `publicly_accessible = true`.

Investigation

1. Confirm the RDS instance identifier and VPC/subnet.
2. Check security groups attached to RDS: `aws rds describe-db-instances --db-instance-identifier <id>` and `aws ec2 describe-security-groups`.
3. Check AWS Config timeline to find change event and IAM principal that made the change.

Mitigation

1. Immediately change RDS to non-public (Terraform or CLI):

```bash
aws rds modify-db-instance --db-instance-identifier <id> --no-publicly-accessible --apply-immediately
```

2. If the security group allows 0.0.0.0/0, revoke those rules:

```bash
aws ec2 revoke-security-group-ingress --group-id <sg-id> --protocol tcp --port 5432 --cidr 0.0.0.0/0
```

3. Rotate database credentials (create new secrets in Secrets Manager and update services to use them).

Prevention

- Enforce Terraform and GitOps: run Terraform plan as part of PR checks; block direct console changes via IAM permissions.
- Use AWS Config rules and GuardDuty to alert on publicly accessible RDS.
- Harden IAM so only automation roles can change RDS properties.

Post-incident

- Run forensics using CloudTrail/Config to understand root cause.
- Update playbooks and add tighter CI checks.
