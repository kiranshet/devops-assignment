# AWS High-Level Architecture

## Architecture Overview

The application uses a highly available, private-first AWS architecture.

### Traffic Flow

Internet
→ CloudFront
→ S3 (React Frontend)

API requests
→ Application Load Balancer / Istio Ingress Gateway
→ Amazon EKS
→ Node.js Microservices
→ Amazon RDS MySQL

## AWS Components

### Networking

- Amazon VPC
- Multiple Availability Zones
- Public subnets
- Private application subnets
- Private database subnets
- Internet Gateway
- NAT Gateway
- Bastion Host
- Route Tables
- Security Groups

### Application Layer

Amazon EKS hosts the Node.js microservices in private subnets.

Istio provides:

- Ingress traffic management
- Service-to-service communication
- Canary deployments
- Traffic routing between stable and canary versions

### Database Layer

Amazon RDS MySQL is deployed in the private database tier.

Production architecture uses Multi-AZ capability for high availability.

### Frontend

The React frontend is hosted in Amazon S3 and delivered through Amazon CloudFront.

### CI/CD

GitHub
→ GitHub Actions
→ Security Tests
→ Docker Build
→ Amazon ECR
→ GitOps repository update
→ Argo CD
→ Amazon EKS

### Security

- AWS Secrets Manager for database credentials
- IAM least-privilege roles
- AWS KMS encryption
- Private subnets for application/database workloads
- Security groups for network restrictions
- Container vulnerability scanning
- Infrastructure security scanning

### Observability

Amazon EKS workloads are monitored using:

- Prometheus
- Grafana
- Loki
- Grafana Alloy
- Alertmanager
- CloudWatch

Metrics include CPU, memory, network, request rate, error rate and response latency.

## Architecture Diagram

                         INTERNET
                             |
                   AWS VPC / ap-south-1
                             |
        +------------------------------------------------+
        |                                                |
        |   PUBLIC SUBNETS                               |
        |                                                |
        |   Internet Gateway                             |
        |         |                                      |
        |   ALB / Istio Ingress                          |
        |         |                                      |
        |   Bastion Host        NAT Gateway              |
        |                                                |
        |---------------- PRIVATE SUBNETS ---------------|
        |                                                |
        |   Amazon EKS                                  |
        |                                                |
        |   +-------------------------------+            |
        |   | Istio                         |            |
        |   |   |                           |            |
        |   |   +--> Stable Pods            |            |
        |   |   +--> Canary Pods            |            |
        |   |                               |            |
        |   | Node.js Microservices         |            |
        |   +---------------+---------------+            |
        |                   |                            |
        |                   v                            |
        |             Amazon RDS MySQL                   |
        |              Private Subnets                   |
        |                                                |
        +------------------------------------------------+

     Security / Management
     ---------------------
     AWS Secrets Manager
     AWS KMS
     IAM

     CI/CD / GitOps
     --------------
     GitHub
       |
     GitHub Actions
       |
     Amazon ECR
       |
     Argo CD
       |
     Amazon EKS

     Observability
     -------------
     Prometheus → Grafana
     Alloy → Loki
     Alertmanager → Email/Slack
     CloudWatch