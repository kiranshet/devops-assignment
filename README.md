# DevOps Assignment

Senior-level AWS DevOps implementation covering infrastructure provisioning, CI/CD, GitOps, Kubernetes, security, observability, cost optimization and automation.

## Architecture

The solution uses a private-first AWS architecture with workloads deployed across multiple Availability Zones.

Main components:

- Amazon VPC
- Public and private subnets
- NAT Gateway
- Bastion Host
- Amazon EKS
- Istio
- Amazon RDS MySQL
- Application Load Balancer / Istio Ingress
- Amazon S3
- Amazon CloudFront
- Amazon ECR
- AWS Secrets Manager
- AWS KMS
- Prometheus
- Grafana
- Loki
- Grafana Alloy
- Alertmanager
- CloudWatch
- GitHub Actions
- Argo CD

Detailed architecture:

`docs/architecture.md`

## Repository Structure

```text
devops-assignment/
├── Terraform/
├── GitOps/
│   └── staging/
├── scripts/
├── docs/
│   ├── architecture.md
│   ├── security.md
│   ├── cost-optimization.md
│   └── error-budget-policy.md
├── .github/
│   └── workflows/
└── README.md


Infrastructure

Terraform provisions:

VPC
Public/private subnets across Availability Zones
Internet Gateway
NAT Gateway
Bastion Host
EKS cluster
EKS managed node group
RDS MySQL
Security Groups
IAM roles
S3 remote Terraform state
DynamoDB state locking

Terraform follows reusable module-based design and uses:

variables.tf
outputs.tf
locals.tf
Reusable modules
Remote state
State locking
Application

The application is a Node.js API containerized with Docker.

Example response:

{
  "application": "DevOps Assignment API",
  "status": "running",
  "version": "v2",
  "environment": "staging"
}
CI/CD Pipeline

The CI/CD pipeline is implemented using GitHub Actions.

Flow:

Developer
   |
   v
GitHub
   |
   v
GitHub Actions
   |
   +--> Application Tests
   |
   +--> Security Scanning
   |
   +--> Docker Build
   |
   v
Amazon ECR
   |
   v
GitOps Repository
   |
   v
Argo CD
   |
   v
Amazon EKS

The pipeline performs:

Source checkout
Application testing
Security scanning
Docker image build
Push to Amazon ECR
GitOps manifest update
Argo CD synchronization
Kubernetes deployment
GitOps

Argo CD manages Kubernetes deployments.

Application:

devops-assignment-staging

Configuration:

Automated sync enabled
Prune enabled
Self-heal enabled
Git repository as the source of truth
Staging deployment through GitOps
Canary Deployment

Istio and Argo Rollouts are used for progressive delivery.

Example traffic progression:

10% Canary
   |
   v
25% Canary
   |
   v
50% Canary
   |
   v
100% Canary

Traffic can be gradually shifted from the stable version to the new version while monitoring application health.

Kubernetes

The application runs in Amazon EKS using:

Deployments
Services
ConfigMaps
Secrets integration
Ingress Gateway
Istio Gateway
Istio VirtualService
Argo Rollouts
Readiness probes
Liveness probes

Application workloads run in private subnets.

Security

Security controls include:

AWS Secrets Manager
Automatic RDS secret rotation
Fine-grained IAM roles
ECR pull-only permissions for worker nodes
Security Groups
Private subnets
KMS encryption
Container vulnerability scanning
Infrastructure security scanning
Dependency scanning

Detailed security documentation:

docs/security.md

Observability

Monitoring stack:

Kubernetes
    |
    +--> Prometheus
    |       |
    |       v
    |    Grafana
    |
    +--> Grafana Alloy
            |
            v
           Loki

CloudWatch is used for AWS infrastructure and database metrics.

Grafana dashboard includes:

Application log volume
HTTP 4xx error count
CPU usage
Memory usage
HTTP request rate
Response latency

Alerting includes high CPU monitoring and email notifications.

Logging

Grafana Alloy collects Kubernetes container logs and forwards them to Loki.

Loki provides centralized log storage for:

Application logs
Istio access logs
Kubernetes logs
Monitoring components
Error Budget

Service Level Objective:

99.9% monthly availability / successful request SLO

Error budget:

0.1%

Approximate monthly error budget:

43.2 minutes

Policy:

Warning at 50% budget consumption
Critical at 80%
Release restrictions when budget is exhausted

Detailed policy:

docs/error-budget-policy.md

Cost Optimization

Cost-saving practices include:

Right-sized EKS nodes
Autoscaling
Appropriate RDS sizing
S3 lifecycle policies
gp3 EBS volumes
Log retention
Removal of unused resources
VPC endpoints where appropriate
AWS Cost Explorer and Budgets

Detailed strategy:

docs/cost-optimization.md

Deployment
Terraform

Initialize Terraform:

terraform init

Review changes:

terraform plan

Apply infrastructure:

terraform apply
Kubernetes

Verify cluster:

kubectl get nodes

Verify application:

kubectl get pods -n devops-assignment

Verify services:

kubectl get svc -n devops-assignment
Argo CD

Verify GitOps application:

kubectl get applications -n argocd

Expected state:

Synced
Healthy
Git Branching Strategy

Recommended workflow:

feature/*
    |
    v
Pull Request
    |
    v
main
    |
    v
GitHub Actions
    |
    v
Staging

Guidelines:

Create feature branches for changes.
Use pull requests for code review.
Protect the main branch.
Require successful CI checks before merge.
Keep commits small and meaningful.
Use descriptive commit messages.
Disaster Recovery

The architecture supports recovery through:

Terraform Infrastructure as Code
Remote Terraform state
RDS automated backups
Multi-AZ database capability
Container images stored in ECR
GitOps configuration stored in Git
Kubernetes manifests maintained as code

Infrastructure can be recreated using Terraform and application workloads redeployed through Argo CD.

Troubleshooting

Useful Kubernetes commands:

kubectl get pods -A
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl get svc -n <namespace>
kubectl get ingress -A

Istio troubleshooting:

istioctl proxy-status
istioctl analyze -A
Assignment Documentation
Area	Documentation
Architecture	docs/architecture.md
Security	docs/security.md
Cost Optimization	docs/cost-optimization.md
Error Budget	docs/error-budget-policy.md
Conclusion

This project demonstrates a production-oriented DevOps platform using AWS, Terraform, Kubernetes, GitHub Actions, GitOps, Istio, Prometheus, Grafana, Loki and AWS security services.

The design focuses on high availability, private networking, secure deployments, progressive delivery, observability, automation and cost awareness.