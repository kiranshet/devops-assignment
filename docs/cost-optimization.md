# Cost Optimization

## Cost-Saving Strategies

### EKS
- Use managed node groups with minimum and maximum scaling limits.
- Use Horizontal Pod Autoscaler where appropriate.
- Scale non-production environments down when not required.
- Avoid unnecessary worker nodes and oversized instances.

### NAT Gateway
- NAT Gateway is used for private subnet internet access.
- Production workloads should minimize unnecessary outbound traffic.
- VPC endpoints can be used for AWS services such as S3 and ECR to reduce NAT Gateway traffic costs.

### RDS
- Use an appropriately sized DB instance.
- Enable automated backups with an appropriate retention period.
- Monitor CPU, memory, storage, and database connections.
- Use Multi-AZ for production availability requirements.

### Load Balancing
- Use a shared Application Load Balancer where appropriate instead of creating unnecessary load balancers.
- Remove unused load balancers and target groups.

### Storage
- Use gp3 EBS volumes where appropriate.
- Configure S3 lifecycle policies to transition older objects to lower-cost storage classes.
- Remove unused snapshots and unattached EBS volumes.

### Monitoring
- Configure log retention policies for Loki and CloudWatch.
- Avoid storing unnecessary high-volume debug logs in production.
- Review Prometheus metrics retention periodically.

## Environment Strategy

Development/staging environments should use smaller resources than production.

Production capacity should be based on actual workload and monitored using CPU, memory, request rate, latency, and database metrics.

## Cost Monitoring

AWS Cost Explorer and AWS Budgets should be used to monitor monthly spending and detect unexpected cost increases.