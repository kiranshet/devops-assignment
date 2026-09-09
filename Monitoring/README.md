# Monitoring and Observability

## Stack

- Prometheus - Kubernetes and infrastructure metrics
- Grafana - dashboards and alerting
- Loki - centralized Kubernetes logs
- Grafana Alloy - log collection and forwarding to Loki
- Alertmanager/Grafana Alerting - alert notifications
- CloudWatch - AWS service metrics

## Grafana Dashboard

The staging dashboard includes:

1. Application Log Volume
2. HTTP Error Count (4xx)
3. CPU and Memory Usage
4. HTTP Request Rate
5. Response Time / Latency

## Logging Flow

Kubernetes Pods
    |
Grafana Alloy
    |
Loki
    |
Grafana

## Metrics Flow

Kubernetes / Node Exporter
    |
Prometheus
    |
Grafana

## Alerting

A High CPU Usage alert is configured with a threshold of 80% and a 5-minute pending period.

## Log Labels

Loki logs include labels such as:

- namespace
- pod
- container
- app
- job
- service_name
- instance
- stream

## Retention and Cost

Production deployments should configure appropriate Prometheus and Loki retention periods and avoid unnecessary high-volume debug logging.
