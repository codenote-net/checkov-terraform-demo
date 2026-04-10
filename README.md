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

All 37 failed checks from CI (Checkov 3.2.517):

**S3 (`aws_s3_bucket.data`)**

| Check ID | Description |
|----------|-------------|
| CKV_AWS_18 | S3 bucket access logging disabled |
| CKV_AWS_20 | S3 bucket allows public READ access |
| CKV_AWS_21 | S3 bucket versioning disabled |
| CKV_AWS_144 | S3 bucket missing cross-region replication |
| CKV_AWS_145 | S3 bucket not encrypted with KMS |
| CKV2_AWS_6 | S3 bucket missing public access block |
| CKV2_AWS_61 | S3 bucket missing lifecycle configuration |
| CKV2_AWS_62 | S3 bucket event notifications disabled |

**Security Group (`aws_security_group.web`)**

| Check ID | Description |
|----------|-------------|
| CKV_AWS_23 | Security group rules missing descriptions |
| CKV_AWS_24 | SSH (22) open to 0.0.0.0/0 |
| CKV_AWS_25 | RDP (3389) open to 0.0.0.0/0 |
| CKV_AWS_260 | HTTP (80) open to 0.0.0.0/0 |
| CKV_AWS_382 | Egress open to 0.0.0.0/0 on all ports |
| CKV2_AWS_5 | Security group not attached to any resource |

**RDS (`aws_db_instance.main`)**

| Check ID | Description |
|----------|-------------|
| CKV_AWS_16 | RDS storage encryption disabled |
| CKV_AWS_17 | RDS publicly accessible |
| CKV_AWS_118 | RDS enhanced monitoring disabled |
| CKV_AWS_129 | RDS logging disabled |
| CKV_AWS_157 | RDS Multi-AZ disabled |
| CKV_AWS_161 | RDS IAM authentication disabled |
| CKV_AWS_226 | RDS auto minor version upgrade disabled |
| CKV_AWS_293 | RDS deletion protection disabled |
| CKV2_AWS_60 | RDS copy tags to snapshots disabled |

**IAM (`aws_iam_policy.admin`)**

| Check ID | Description |
|----------|-------------|
| CKV_AWS_62 | IAM policy grants full administrative privileges |
| CKV_AWS_63 | IAM policy allows "*" as action |
| CKV_AWS_286 | IAM policy allows privilege escalation |
| CKV_AWS_287 | IAM policy allows credentials exposure |
| CKV_AWS_288 | IAM policy allows data exfiltration |
| CKV_AWS_289 | IAM policy allows resource exposure without constraints |
| CKV_AWS_290 | IAM policy allows write access without constraints |
| CKV_AWS_355 | IAM policy allows "*" as resource for restrictable actions |
| CKV2_AWS_40 | IAM policy grants full IAM privileges |

**CloudTrail (`aws_cloudtrail.main`)**

| Check ID | Description |
|----------|-------------|
| CKV_AWS_35 | CloudTrail logs not encrypted with KMS |
| CKV_AWS_36 | CloudTrail log file validation disabled |
| CKV_AWS_67 | CloudTrail not enabled in all regions |
| CKV_AWS_252 | CloudTrail missing SNS topic |
| CKV2_AWS_10 | CloudTrail not integrated with CloudWatch Logs |

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
