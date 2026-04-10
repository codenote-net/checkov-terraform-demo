# checkov-terraform-demo

A demo repository that uses [Checkov](https://github.com/bridgecrewio/checkov) to detect vulnerabilities in Terraform code.

It provides intentionally vulnerable code in `insecure/` alongside hardened code in `secure/`, so you can see how static analysis detects and resolves security issues.

## What is Checkov?

Checkov is an open-source static analysis tool developed by Bridgecrew (Prisma Cloud). It supports Terraform, CloudFormation, Kubernetes, Dockerfile, and many other frameworks, detecting security and compliance issues.

## Directory structure

```
├── insecure/          # Intentionally vulnerable Terraform code
│   ├── provider.tf
│   ├── s3.tf          # No encryption, public access, versioning disabled
│   ├── sg.tf          # All ports open, SSH exposed to 0.0.0.0/0
│   ├── rds.tf         # No encryption, public access, hardcoded password
│   ├── iam.tf         # Wildcard Action/Resource (*)
│   └── cloudtrail.tf  # No log encryption, validation disabled
├── secure/            # Hardened Terraform code (all Checkov checks passed)
│   ├── provider.tf
│   ├── s3.tf          # KMS encryption, public access block, versioning, etc.
│   ├── sg.tf          # Restricted ports, SSH limited to specific CIDR
│   ├── rds.tf         # Encrypted, private, Multi-AZ, IAM auth
│   ├── iam.tf         # Least privilege policy
│   └── cloudtrail.tf  # KMS encryption, log validation, CloudWatch integration
└── .github/workflows/
    └── checkov.yml    # GitHub Actions automated scanning
```

## Local usage

```bash
# Install Checkov
pip install checkov

# Scan vulnerable code (many FAILEDs expected)
checkov -d insecure/ --framework terraform

# Scan hardened code (all PASSED)
checkov -d secure/ --framework terraform

# Compact output
checkov -d insecure/ --framework terraform --compact
```

## Scan results summary

### insecure/ — Passed 13 / Failed 37

| Check ID | Description | Resource |
|----------|-------------|----------|
| CKV_AWS_18 | S3 bucket access logging disabled | `aws_s3_bucket.data` |
| CKV_AWS_20 | S3 bucket allows public READ access | `aws_s3_bucket.data` |
| CKV_AWS_21 | S3 bucket versioning disabled | `aws_s3_bucket.data` |
| CKV_AWS_145 | S3 bucket not encrypted with KMS | `aws_s3_bucket.data` |
| CKV2_AWS_6 | S3 bucket missing public access block | `aws_s3_bucket.data` |
| CKV_AWS_144 | S3 bucket missing cross-region replication | `aws_s3_bucket.data` |
| CKV_AWS_23 | Security group rules missing descriptions | `aws_security_group.web` |
| CKV_AWS_24 | SSH (22) open to 0.0.0.0/0 | `aws_security_group.web` |
| CKV_AWS_25 | RDP (3389) open to 0.0.0.0/0 | `aws_security_group.web` |
| CKV_AWS_260 | HTTP (80) open to 0.0.0.0/0 | `aws_security_group.web` |
| CKV_AWS_16 | RDS storage encryption disabled | `aws_db_instance.main` |
| CKV_AWS_17 | RDS publicly accessible | `aws_db_instance.main` |
| CKV_AWS_161 | RDS IAM authentication disabled | `aws_db_instance.main` |
| CKV_AWS_157 | RDS Multi-AZ disabled | `aws_db_instance.main` |
| CKV_AWS_293 | IAM policy allows wildcard Action | `aws_iam_policy.admin` |
| CKV_AWS_289 | IAM policy allows wildcard Resource | `aws_iam_policy.admin` |
| CKV_AWS_35 | CloudTrail logs not encrypted with KMS | `aws_cloudtrail.main` |
| CKV_AWS_36 | CloudTrail log file validation disabled | `aws_cloudtrail.main` |
| CKV_AWS_67 | CloudTrail not enabled in all regions | `aws_cloudtrail.main` |

> The above is a subset of key findings. Run `checkov -d insecure/` to see all 37 failures.

### secure/ — Passed 111 / Failed 0

All checks passed.

## GitHub Actions

Checkov scans run automatically on push and pull requests. Results are posted as PR comments.

- **insecure/**: `soft_fail: true` — failures do not block CI (expected to fail)
- **secure/**: `soft_fail: false` — any failure blocks CI

## References

- [Checkov (GitHub)](https://github.com/bridgecrewio/checkov)
- [Checkov Documentation](https://www.checkov.io/1.Welcome/Quick%20Start.html)
- [Prisma Cloud Policy Reference](https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies)
