# Istio / Kubernetes Traffic Troubleshooting

## Problem Statement

When a microservice is not receiving traffic even though the pod, Kubernetes Service, Ingress Gateway, and Istio configuration appear to be enabled, troubleshoot the traffic path layer by layer.

Expected traffic flow:

`Client → AWS Load Balancer → Istio Ingress Gateway → Gateway → VirtualService → Kubernetes Service → Pod`

## 1. Check Pod Health

Verify that application pods are running and ready:

```bash
kubectl get pods -n devops-assignment -o wide
```

Check a specific pod:

```bash
kubectl describe pod <pod-name> -n devops-assignment
```

Look for:

* Pod status `Running`
* Ready containers
* Failed readiness/liveness probes
* Container restarts
* Scheduling failures

If the application container is unhealthy, fix the pod before troubleshooting Istio.

## 2. Check Kubernetes Service and Endpoints

Verify the Service:

```bash
kubectl get svc -n devops-assignment
```

Verify that the Service has endpoints:

```bash
kubectl get endpoints -n devops-assignment
```

If the Service has no endpoints, check its selector:

```bash
kubectl describe svc <service-name> -n devops-assignment
```

Then compare the Service selector with pod labels:

```bash
kubectl get pods -n devops-assignment --show-labels
```

A selector mismatch is a common reason for traffic not reaching the application.

## 3. Check Istio Gateway and VirtualService

Verify Istio resources:

```bash
kubectl get gateway,virtualservice -n devops-assignment
```

Inspect the Gateway:

```bash
kubectl describe gateway <gateway-name> -n devops-assignment
```

Inspect the VirtualService:

```bash
kubectl describe virtualservice <virtualservice-name> -n devops-assignment
```

Check:

* Gateway selector
* Host configuration
* HTTP route
* Destination service
* Destination port
* Canary/stable routing weights

For example, a stable deployment should route 100% traffic to the stable service when canary traffic is disabled.

## 4. Check Istio Proxy Status

Verify that the Envoy sidecars are connected:

```bash
istioctl proxy-status
```

The application pod should appear with a healthy synchronization status.

If the proxy is not synchronized, inspect the proxy configuration:

```bash
istioctl proxy-config listeners <pod-name> -n devops-assignment
```

Check clusters:

```bash
istioctl proxy-config clusters <pod-name> -n devops-assignment
```

These commands help identify missing listeners, services, or routing configuration.

## 5. Run Istio Configuration Analysis

Run:

```bash
istioctl analyze -n devops-assignment
```

This can identify common configuration problems such as:

* Invalid Gateway configuration
* VirtualService conflicts
* Service port mismatches
* Missing workloads
* Incorrect Istio configuration

Fix reported errors before continuing.

## 6. Check Istio Proxy Logs

Inspect Envoy logs:

```bash
kubectl logs <pod-name> -n devops-assignment -c istio-proxy
```

Look for:

* Connection failures
* Upstream connection errors
* HTTP 4xx/5xx responses
* TLS errors
* Route configuration errors
* Connection resets

For ingress gateway logs:

```bash
kubectl logs -n istio-system \
  -l istio=ingressgateway \
  -c istio-proxy
```

## 7. Test Service Connectivity Internally

Test the Kubernetes Service from inside the cluster:

```bash
kubectl exec -it <pod-name> -n devops-assignment -- \
  curl http://devops-assignment-api
```

If this works, Kubernetes Service-to-Pod communication is functioning.

If it fails, investigate:

* Service selector
* Endpoints
* Service port
* Target port
* NetworkPolicy
* Application listener

## 8. Test External Traffic

Obtain the Istio LoadBalancer address:

```bash
kubectl get svc istio-ingressgateway -n istio-system
```

Test the application:

```bash
curl http://<ISTIO-LOADBALANCER-IP-OR-DNS>/
```

If external traffic fails but internal service access works, focus on:

* AWS Load Balancer
* Istio Ingress Gateway
* Gateway configuration
* VirtualService configuration
* Security groups
* Network connectivity

## 9. Check Application Logs

Inspect application logs:

```bash
kubectl logs <pod-name> -n devops-assignment -c <application-container>
```

Verify that the application is listening on the expected port.

Also check container configuration:

```bash
kubectl describe pod <pod-name> -n devops-assignment
```

## Troubleshooting Summary

The troubleshooting process should follow the traffic path from the outside toward the application:

1. Verify AWS Load Balancer accessibility.
2. Verify Istio Ingress Gateway.
3. Verify Gateway configuration and selector.
4. Verify VirtualService routing.
5. Verify Envoy proxy configuration.
6. Verify Kubernetes Service.
7. Verify Service endpoints.
8. Verify pod readiness and application health.
9. Check application and Istio proxy logs.
10. Test connectivity from inside and outside the cluster.

## Challenges and Resolutions

### Service had no traffic

Checked the Kubernetes Service and endpoints to verify that the Service selector correctly matched the application pods.

### Istio routing issue

Validated the Gateway and VirtualService configuration and confirmed that traffic was routed to the correct stable/canary service.

### Canary deployment

Verified rollout status and traffic weights before changing production traffic. Canary traffic can be gradually increased after validating application health.

### Proxy configuration

Used `istioctl proxy-status`, `istioctl proxy-config`, and `istioctl analyze` to validate Envoy synchronization and routing configuration.

### External connectivity

Validated the AWS LoadBalancer, Istio ingress gateway, and network/security configuration when internal connectivity worked but external traffic failed.

## Conclusion

Istio troubleshooting should be performed layer by layer rather than changing multiple configurations at once. Starting from LoadBalancer → Gateway → VirtualService → Service → Endpoints → Pod makes it easier to isolate the exact failure point and reduce recovery time.
