# Security & Compliance

## Secrets Management

AWS Secrets Manager is used for RDS database credentials.

- Secrets are managed by AWS RDS.
- Automatic rotation is enabled every 7 days.
- Database credentials are not stored in source code or Docker images.

## IAM

Fine-grained IAM roles are used instead of broad administrator permissions.

### EKS Node Role

`devops-assignment-dev-eks-node-role`

Attached permissions:
- AmazonEKS_CNI_Policy
- AmazonEKSWorkerNodePolicy
- AmazonEC2ContainerRegistryPullOnly

The worker nodes have ECR pull-only access and do not use AdministratorAccess.

### EBS CSI Driver

A dedicated IAM role is used:

`AmazonEKS_EBS_CSI_DriverRole`

Permission:
- AmazonEBSCSIDriverPolicy

## Encryption

RDS storage encryption is enabled using AWS KMS.

- Storage encryption: Enabled
- KMS key: AWS managed RDS KMS key
- Encryption is applied to RDS storage at rest.

Kubernetes/EKS secrets encryption with a customer-managed KMS key is not enabled in the current implementation.

## Container Security

The CI/CD pipeline performs application security scanning before image deployment.

Amazon ECR image scanning is also enabled.

The latest scanned image reported:
- Critical: 2
- High: 7
- Medium: 1

These findings are documented for remediation and should be addressed by updating the affected base OS/OpenSSL packages before production deployment.

## Infrastructure Security

- Private subnets are used for application and database workloads.
- Security groups restrict network access.
- RDS is not directly exposed to the internet.
- EKS worker nodes run in private subnets.
- ALB/Istio provides controlled external access to the application.

## Security Principles

- Least privilege IAM
- Secrets stored outside source code
- Encryption at rest
- Private network architecture
- Container vulnerability scanning
- Infrastructure-as-Code security scanning
- Automated security checks in CI/CD