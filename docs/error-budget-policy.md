# Error Budget Policy

## Service Level Objective (SLO)

The application targets a **99.9% monthly availability / successful request SLO**.

## Error Budget

* SLO: 99.9%
* Error budget: 0.1%
* Approximate monthly error budget: 43.2 minutes

## Measurement

The error budget is measured using application and Istio HTTP error metrics/logs, with focus on HTTP 5xx errors.

## Alert Thresholds

* **Warning:** More than 50% of the monthly error budget is consumed.
* **Critical:** More than 80% of the monthly error budget is consumed.
* **Exhausted:** 100% of the error budget is consumed.

## Release Policy

When the error budget is healthy, normal releases can continue.

When more than 80% of the error budget is consumed, the team should prioritize reliability improvements and avoid unnecessary risky releases.

When the error budget is exhausted, production releases should be restricted to critical fixes until service reliability returns to the target.

## Review

The SLO and error budget should be reviewed monthly and adjusted based on production requirements.
