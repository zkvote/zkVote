---
title: 🚨 Security Scan Findings {{ date | date('YYYY-MM-DD') }}
labels: security, confidential
assignees: security-team
---

# Security Scan Results

**Date:** {{ date | date('YYYY-MM-DD') }}
**Scan Type:** Automated Security Scan

## High Severity Findings

This automated scan has detected potential security issues that require immediate attention.

Please check the [full security report]({{ github.server_url }}/{{ github.repository }}/actions/runs/{{ github.run_id }}) for details.

## AI Security Analysis

The CertiK AI and DevSec-GPT analysis has identified potential issues that require human review.

## Next Steps

1. Analyze the findings in the security artifacts
2. Prioritize issues based on severity and impact
3. Create remediation tasks
4. Update this issue with an action plan
5. Verify quantum-safe signature integrity

**Note:** This is an automatically generated issue. Please do not share sensitive security details in public channels.
