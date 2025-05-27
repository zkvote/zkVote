---
title: 📉 Performance Degradation Detected {{ date | date('YYYY-MM-DD HH:mm') }}
labels: performance, investigation-needed
assignees: backend-team, devops-team
---

# Performance Degradation Detected

**Time of Detection:** {{ date | date('YYYY-MM-DD HH:mm:ss') }} UTC
**Affected Component(s)/Endpoint(s):** [e.g., API /vote endpoint, Frontend load time, Gas usage for X function]
**Environment:** [e.g., Production, Staging]

## Performance Issue Description

Automated performance monitoring has detected a degradation or issue.
Details can be found in the performance report from the monitoring run.

[Workflow Run Link: {{ github.server_url }}/{{ github.repository }}/actions/runs/{{ github.run_id }}]
[Link to Performance Report Artifact if available]

## Key Metrics & Thresholds

| Metric                 | Observed Value | Expected/Previous Value | Threshold |
| ---------------------- | -------------- | ----------------------- | --------- |
| {{ env.METRIC_NAME_1 }}  | {{ env.METRIC_VALUE_1 }} | {{ env.METRIC_EXPECTED_1 }} | {{ env.METRIC_THRESHOLD_1 }} |
| {{ env.METRIC_NAME_2 }}  | {{ env.METRIC_VALUE_2 }} | {{ env.METRIC_EXPECTED_2 }} | {{ env.METRIC_THRESHOLD_2 }} |
<!-- Add more metrics as needed, populated by the workflow -->

## Potential Impact

[e.g., Slower API response times, Increased user-perceived latency, Higher gas costs]

## Next Steps

1.  **Verify Degradation:** Confirm the issue with current monitoring dashboards (e.g., Datadog, Grafana, Lighthouse reports).
2.  **Analyze Logs & Traces:** Investigate logs and traces for the affected components around the time of detection.
3.  **Identify Root Cause:** Look for recent deployments, configuration changes, traffic spikes, or resource bottlenecks.
4.  **Compare with Baseline:** Check historical performance data to understand the extent of the degradation.
5.  **Develop Optimization Plan:** If confirmed, plan and implement necessary optimizations.
6.  **Update Benchmarks:** Adjust performance benchmarks if the system's behavior has intentionally changed.

Please update this issue with your findings and resolution.
