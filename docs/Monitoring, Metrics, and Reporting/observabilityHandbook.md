# zkVote: Observability Handbook

**Document ID:** ZKV-OBS-2025-001
**Version:** 1.0
**Date:** 2025-04-25
**Author:** Cass402
**Classification:** Internal

---

## Document Control

| Version | Date       | Author  | Description of Changes |
| ------- | ---------- | ------- | ---------------------- |
| 1.0     | 2025-04-25 | Cass402 | Initial version        |

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Observability Infrastructure](#2-observability-infrastructure)
3. [Logging Strategy](#3-logging-strategy)
4. [Metrics and Monitoring](#4-metrics-and-monitoring)
5. [Distributed Tracing](#5-distributed-tracing)
6. [Alerting and Incident Response](#6-alerting-and-incident-response)
7. [Dashboards and Visualization](#7-dashboards-and-visualization)
8. [Performance Monitoring](#8-performance-monitoring)
9. [Health Checks and SLOs](#9-health-checks-and-slos)
10. [Troubleshooting Guide](#10-troubleshooting-guide)
11. [Continuous Improvement](#11-continuous-improvement)
12. [Appendices](#12-appendices)

---

## 1. Introduction

### 1.1 Purpose

This handbook provides a comprehensive guide to the observability practices and infrastructure for the zkVote protocol. It serves as the definitive reference for all team members involved in monitoring, maintaining, and troubleshooting the zkVote system across all environments.

### 1.2 Scope

This document covers:

- Observability infrastructure and tooling
- Logging standards and implementation
- Metrics collection and monitoring
- Distributed tracing across components
- Alerting configuration and incident response
- Dashboard design and usage
- Performance monitoring strategies
- Health checks and service level objectives
- Privacy-preserving observability practices
- Troubleshooting methodologies

### 1.3 Observability Principles

The zkVote observability strategy is guided by the following core principles:

1. **Comprehensive Visibility**: Maintain visibility into all system components while respecting privacy
2. **Actionable Insights**: Focus on metrics and logs that drive action, not just information
3. **Privacy by Design**: Apply privacy-preserving techniques to all observability data
4. **Proactive Detection**: Identify issues before they affect users
5. **Rapid Diagnosis**: Enable quick root cause analysis through correlated observability data
6. **Cross-Component Visibility**: Trace requests and operations across service boundaries
7. **Security First**: Handle observability data with appropriate security controls
8. **Efficiency**: Optimize for resource consumption and cost
9. **Continuous Improvement**: Regularly evaluate and enhance observability practices

### 1.4 Observability Roles and Responsibilities

| Role                  | Responsibilities                                 | Primary Tools                       |
| --------------------- | ------------------------------------------------ | ----------------------------------- |
| **SRE Team**          | Overall observability strategy, platform health  | All tools                           |
| **Development Teams** | Service-specific instrumentation, service health | Logs, Traces, Service dashboards    |
| **Security Team**     | Security observability, compliance monitoring    | Security dashboards, audit logs     |
| **Data Team**         | Data pipeline monitoring, analytics reliability  | Data-specific dashboards            |
| **Support Team**      | User impact monitoring, issue escalation         | User-facing metrics, incident tools |

---

## 2. Observability Infrastructure

### 2.1 Architecture Overview

```
                ┌─────────────────┐
                │ Observability   │
                │ Platform        │
                └────────┬────────┘
                         │
   ┌─────────────────────┼─────────────────────┐
   │                     │                     │
┌──▼─────────┐       ┌───▼─────────┐       ┌───▼─────────┐
│ Log        │       │ Metrics     │       │ Tracing     │
│ Pipeline   │       │ Pipeline    │       │ Pipeline    │
└──┬─────────┘       └───┬─────────┘       └───┬─────────┘
   │                     │                     │
┌──▼─────────┐       ┌───▼─────────┐       ┌───▼─────────┐
│ Log        │       │ Metrics     │       │ Tracing     │
│ Storage    │       │ Storage     │       │ Storage     │
└──┬─────────┘       └───┬─────────┘       └───┬─────────┘
   │                     │                     │
   └──────────┬──────────┴──────────┬──────────┘
              │                     │
        ┌─────▼─────┐         ┌─────▼─────┐
        │ Visualization &       │ Alerting │
        │ Alerting Layer        │ Layer    │
        └───────────────────────┴──────────┘
```

### 2.2 Tools and Technologies

| Component               | Primary Technology | Backup/Alternative | Notes                                               |
| ----------------------- | ------------------ | ------------------ | --------------------------------------------------- |
| **Log Management**      | Elasticsearch      | Loki               | ELK stack for primary deployment                    |
| **Log Shipping**        | Fluentd            | Vector             | Deployed as sidecars and centralized collectors     |
| **Metrics Collection**  | Prometheus         | InfluxDB           | Pull-based metrics with push gateway for batch jobs |
| **Metrics Storage**     | Thanos             | Cortex             | Long-term storage with high availability            |
| **Distributed Tracing** | Jaeger             | OpenTelemetry      | Sampling based on configuration                     |
| **Visualization**       | Grafana            | Kibana             | Central dashboard platform                          |
| **Alerting**            | AlertManager       | Grafana Alerting   | Rule-based alerting with routing                    |
| **On-Call Management**  | PagerDuty          | Opsgenie           | Escalation policies by service                      |
| **Status Page**         | Statuspage.io      |                    | Public-facing status communication                  |

### 2.3 Deployment Architecture

- **Production**: Full HA setup with redundancy across availability zones
- **Staging**: Scaled-down version of production setup
- **Development**: Lightweight setup focused on developer experience

**Common components and configurations**:

- **Central Collection Tier**:

  - Elasticsearch cluster (3+ nodes)
  - Prometheus HA pair with Thanos
  - Jaeger Collector cluster

- **Agent Tier**:

  - Fluentd or Vector agents on all nodes
  - Prometheus Node Exporters
  - Service-specific exporters
  - OpenTelemetry collectors

- **Visualization Tier**:
  - Grafana cluster with HA
  - Kibana for log exploration
  - Jaeger UI for trace analysis

### 2.4 Data Retention Policies

| Data Type        | Hot Storage | Warm Storage | Cold Storage |
| ---------------- | ----------- | ------------ | ------------ |
| Application Logs | 7 days      | 30 days      | 365 days     |
| System Logs      | 7 days      | 30 days      | 90 days      |
| Metrics          | 15 days     | 90 days      | 365 days     |
| Traces           | 7 days      | 30 days      | —            |
| Audit Logs       | 30 days     | 365 days     | 7 years      |
| Security Events  | 30 days     | 365 days     | 7 years      |

### 2.5 Authentication and Authorization

- **Tool Access**: SSO integration with corporate identity provider
- **RBAC**: Granular permissions by team and role
- **Service Accounts**: Dedicated accounts for automated processes
- **Audit Logging**: All access and changes to observability systems are logged

### 2.6 Network Architecture

- **Data Collection**: Internal network only, no public endpoints
- **Tool Access**: VPN or corporate network required
- **Cross-Region**: Federated collection with regional aggregation
- **Encryption**: All data encrypted in transit (TLS 1.3+)

---

## 3. Logging Strategy

### 3.1 Logging Philosophy

- **Purpose-Driven**: Every log has a defined audience and use case
- **Structured Format**: Consistent JSON for machine processing
- **Context-Rich**: Sufficient context to understand events without lookups
- **Privacy-Aware**: No sensitive data in logs
- **Performance-Conscious**: Appropriate log levels and sampling
- **Correlation-Ready**: Trace IDs included in all service logs

### 3.2 Log Levels and Usage

| Level | Usage                                                | Examples                             | Priority    |
| ----- | ---------------------------------------------------- | ------------------------------------ | ----------- |
| FATAL | System cannot continue                               | Database unavailable                 | Highest     |
| ERROR | Error that affects operation but system can continue | Failed transaction                   | High        |
| WARN  | Potential issue without immediate impact             | Approaching resource limits          | Medium-High |
| INFO  | Normal operational events                            | Vote created, delegation established | Medium      |
| DEBUG | Detailed debugging information                       | Function entry/exit, variable values | Low         |
| TRACE | Very detailed protocol-level logs                    | Raw protocol dumps                   | Lowest      |

> **Note**: Production runs at INFO by default, with dynamic level changes per component.

### 3.3 Log Format Standard

All zkVote services emit JSON logs with this schema:

```json
{
  "timestamp": "2025-04-25T08:12:34.567Z",
  "level": "INFO",
  "service": "vote-processor",
  "instance": "vote-processor-pod-1234",
  "traceId": "1234567890abcdef",
  "spanId": "abcdef1234567890",
  "userId": "<anonymized>",
  "requestId": "req-5678",
  "message": "Vote submitted successfully",
  "context": {
    "voteId": "vote-1234",
    "processingTimeMs": 45,
    "component": "vote-verification",
    "chainId": 1
  },
  "resourceId": {
    "type": "vote",
    "id": "vote-1234"
  }
}
```

### 3.4 Common Logging Patterns

#### 3.4.1 Request Logging

- **Entry**: INFO with method, path, traceId
- **Exit**: INFO with status, duration, same traceId
- **Errors**: ERROR with stack trace and context

Example:

```json
{"level":"INFO","message":"Request started","method":"POST","path":"/api/votes","traceId":"abc123","requestId":"req-5678"}
{"level":"INFO","message":"Request completed","method":"POST","path":"/api/votes","status":201,"durationMs":156,"traceId":"abc123","requestId":"req-5678"}
```

#### 3.4.2 Blockchain Interaction Logging

Include transaction hash, contract, method, chainId, gas used, block number, traceId:

```json
{"level":"INFO","message":"Transaction submitted","contract":"0x1234...5678","method":"submitVote","txHash":"0xabcd...ef01","chainId":1,"traceId":"abc123"}
{"level":"INFO","message":"Transaction confirmed","contract":"0x1234...5678","method":"submitVote","txHash":"0xabcd...ef01","chainId":1,"blockNumber":15481234,"gasUsed":145000,"traceId":"abc123"}
```

#### 3.4.3 Error Logging

Include message, code, stack trace, context, correlation IDs:

```json
{
  "level": "ERROR",
  "message": "Failed to verify vote proof",
  "error": "Invalid proof format",
  "errorCode": "PROOF_INVALID",
  "voteId": "vote-1234",
  "traceId": "abc123",
  "context": { "proofType": "vote", "component": "verifier" }
}
```

### 3.5 Implementation by Component

| Component        | Library                           | Configuration                         | Notes                              |
| ---------------- | --------------------------------- | ------------------------------------- | ---------------------------------- |
| Backend Services | Winston (Node.js), Logback (Java) | JSON formatter, rotating files        | Privacy filters for user data      |
| Smart Contracts  | Events + Indexer                  | Standardized schemas                  | Gas optimization vs. observability |
| Frontend         | Custom logger → backend           | Browser console + API submission      | Selective logging for user privacy |
| Bridge Services  | Structured logger                 | High detail on cross-chain operations | Multiple chain context             |
| Infrastructure   | Native + Fluentd                  | Standardized parsing                  | System and container logs          |

### 3.6 Log Aggregation Pipeline

1. **Collection**
   - App logs → local files → Fluentd/Vector → Kafka
   - Container/system logs → Node agent → Kafka
2. **Processing**
   - Kafka → Processors (parsing, enrichment, filtering)
   - Privacy filtering & anonymization
   - Correlation ID injection
3. **Storage**
   - **Primary**: Elasticsearch (ILM for index lifecycle)
   - **Long-term**: S3-compatible object storage (compressed)
4. **Retention**
   - Hot: 7 days
   - Warm: 30 days
   - Cold: ≥365 days

### 3.7 Log Privacy Controls

- **Data Minimization**: Log only necessary fields
- **Anonymization**: Hash/tokenize PII
- **Filtering**: Strip sensitive fields before storage
- **Access Controls**: Role-based log access
- **Audit**: Record all log access

---

## 4. Metrics and Monitoring

### 4.1 Metrics Collection Approach

zkVote uses a multi-level metrics approach:

- **System Metrics**: Nodes, containers, cloud resources
- **Service Metrics**: App-specific counters, gauges, histograms
- **Business Metrics**: High-level KPIs (votes_processed, active_daos)
- **User Experience Metrics**: RUM data (page load times)
- **Blockchain Metrics**: Chain confirmations, gas usage

### 4.2 Core Metric Types

| Type          | Description               | Collection Method       | Example                      |
| ------------- | ------------------------- | ----------------------- | ---------------------------- |
| **Counter**   | Cumulative events         | Increment on occurrence | votes_processed_total        |
| **Gauge**     | Point-in-time measurement | Direct measurement      | active_connections           |
| **Histogram** | Bucketed distribution     | Bucketed measurements   | request_duration_seconds     |
| **Summary**   | Quantiles on the fly      | Streaming calculation   | vote_processing_time_seconds |

### 4.3 Standard Metric Nomenclature

```
{component}_{metric_name}_{unit}[_{type}]
```

**Examples**:

- `api_request_duration_seconds_histogram`
- `vote_processor_votes_processed_total`
- `bridge_message_queue_length_gauge`

### 4.4 Common Labels/Tags

| Label           | Purpose               | Example Values              |
| --------------- | --------------------- | --------------------------- |
| **service**     | Service identifier    | vote-processor, bridge      |
| **instance**    | Specific instance     | pod-1234                    |
| **environment** | Deployment env        | production, staging         |
| **region**      | Geographical region   | us-east-1, eu-west-1        |
| **version**     | Software version      | 1.2.3                       |
| **chain_id**    | Blockchain identifier | 1 (Ethereum), 137 (Polygon) |

### 4.5 Core Metrics by Component

#### 4.5.1 API & Frontend Services

| Metric                         | Type      | Labels                    |
| ------------------------------ | --------- | ------------------------- |
| `api_requests_total`           | Counter   | method, path, status_code |
| `api_request_duration_seconds` | Histogram | method, path, status_code |
| `api_request_size_bytes`       | Histogram | method, path              |
| `api_response_size_bytes`      | Histogram | method, path              |
| `api_error_total`              | Counter   | method, path, error_type  |
| `api_active_requests`          | Gauge     | method                    |

#### 4.5.2 Vote Processing Services

| Metric                           | Type      | Labels                |
| -------------------------------- | --------- | --------------------- |
| `votes_processed_total`          | Counter   | status, vote_type     |
| `vote_processing_time_seconds`   | Histogram | vote_type, status     |
| `vote_size_bytes`                | Histogram | vote_type             |
| `vote_queue_length`              | Gauge     | —                     |
| `vote_errors_total`              | Counter   | error_type, vote_type |
| `vote_verification_time_seconds` | Histogram | proof_type            |

#### 4.5.3 Bridge Services

| Metric                                   | Type      | Labels                     |
| ---------------------------------------- | --------- | -------------------------- |
| `bridge_messages_sent_total`             | Counter   | source_chain, target_chain |
| `bridge_messages_received_total`         | Counter   | source_chain, target_chain |
| `bridge_message_processing_time_seconds` | Histogram | source_chain, target_chain |
| `bridge_confirmation_time_seconds`       | Histogram | source_chain, target_chain |
| `bridge_gas_used`                        | Histogram | chain_id, operation_type   |
| `bridge_queue_length`                    | Gauge     | source_chain, target_chain |

#### 4.5.4 Database & Cache Services

| Metric                       | Type      | Labels                   |
| ---------------------------- | --------- | ------------------------ |
| `db_query_duration_seconds`  | Histogram | operation, table         |
| `db_queries_total`           | Counter   | operation, table, status |
| `db_connections`             | Gauge     | pool                     |
| `db_connection_errors_total` | Counter   | error_type               |
| `cache_hit_total`            | Counter   | cache_name               |
| `cache_miss_total`           | Counter   | cache_name               |
| `cache_size_bytes`           | Gauge     | cache_name               |
| `cache_evictions_total`      | Counter   | cache_name, reason       |

### 4.6 Infrastructure Metrics

- **Node**: CPU, memory, disk, network IO
- **Container**: CPU, memory, restarts, throttling
- **Network**: Throughput, latency, errors, connection counts
- **Cloud Services**: Service-specific metrics, quotas
- **Kubernetes**: Pod status, deployment status, cluster health

### 4.7 Business & User Experience Metrics

| Metric                          | Type  | Business Impact      |
| ------------------------------- | ----- | -------------------- |
| `vote_creation_rate`            | Gauge | Core usage indicator |
| `active_dao_count`              | Gauge | Customer engagement  |
| `delegate_registration_rate`    | Gauge | Ecosystem growth     |
| `cross_chain_voting_percentage` | Gauge | Cross-chain adoption |
| `feature_usage_percentage`      | Gauge | Feature adoption     |
| `user_error_rate`               | Gauge | User satisfaction    |
| `p95_response_time`             | Gauge | UX performance       |

### 4.8 Metrics Storage and Querying

- **Frequency**: 15s intervals
- **Storage**: Prometheus + Thanos
- **Query**: PromQL
- **Retention**: See §2.4
- **Federation**: Global + regional Prometheus

### 4.9 Metrics Privacy Controls

- **Aggregation**: Aggregate by user
- **Anonymization**: Hash user IDs
- **Minimization**: Collect only necessary metrics
- **Access Controls**: Role-based visibility

---

## 5. Distributed Tracing

### 5.1 Tracing Strategy

- **Coverage**: All services + external deps
- **Correlation**: Propagate trace IDs
- **Context**: Business attributes in spans
- **Consistency**: Standard names/attributes
- **Efficiency**: Adaptive sampling
- **Privacy**: Exclude PII

### 5.2 Instrumentation Standards

#### 5.2.1 Trace Context Propagation

- **W3C Trace Context**: `traceparent`, `tracestate` HTTP headers
- **Messaging**: Custom headers for Kafka/RabbitMQ
- **Cross-Chain**: Custom propagation for blockchain

#### 5.2.2 Standard Span Attributes

| Category     | Examples                                                |
| ------------ | ------------------------------------------------------- |
| HTTP         | `http.method`, `http.url`, `http.status_code`           |
| Database     | `db.system`, `db.operation` (sanitized)                 |
| Messaging    | `messaging.system`, `messaging.destination`             |
| Blockchain   | `blockchain.network`, `blockchain.operation`, `tx.hash` |
| User Context | `user.type` (anonymized role)                           |
| Business     | `vote.id`, `dao.id`, `operation.type`                   |

### 5.3 Sampling Strategy

| Sampling Type     | Rate    | Usage                                          |
| ----------------- | ------- | ---------------------------------------------- |
| Head-Based        | 10–100% | Normal traffic                                 |
| Tail-Based        | 100%    | Errors, slow ops                               |
| Priority Sampling | 100%    | Critical ops (votes, delegations, cross-chain) |
| Default           | 10%     | Routine health checks                          |

- **Dynamic adjustment** based on load

### 5.4 Implementation by Component

| Component       | Library       | Language   | Notes                         |
| --------------- | ------------- | ---------- | ----------------------------- |
| API Services    | OpenTelemetry | Node.js    | Auto + manual spans           |
| Vote Processor  | OpenTelemetry | Rust       | Manual spans                  |
| Bridge Services | OpenTelemetry | Go         | Auto + manual spans           |
| Frontend        | OpenTelemetry | JavaScript | Selective browser tracing     |
| Smart Contracts | Custom proxy  | Solidity   | Event-based tracing           |
| Database Access | OpenTelemetry | Various    | Auto instrumentation          |
| Message Queues  | OpenTelemetry | Various    | Producer/consumer correlation |

### 5.5 Typical Trace Flow

1. **Frontend UI** → 2. **API Gateway** → 3. **Auth** → 4. **Vote Service** → 5. **Proof Generation** → 6. **Vote Processor** → 7. **Blockchain Node** → 8. **Indexer** → 9. **Notification Service**

### 5.6 Trace Storage and Processing

- **Collector**: OpenTelemetry Collector (batched + enhanced)
- **Storage**: Jaeger + Elasticsearch
- **Retention**: 7 days full, 30 days sampled
- **Processing**: Analytics for anomalies

### 5.7 Privacy Controls for Tracing

- **PII Redaction**: Automated removal
- **Attribute Filtering**: Configurable collects
- **Access Control**: RBAC on trace data
- **Sampling**: Lower for sensitive ops

---

## 6. Alerting and Incident Response

### 6.1 Alerting Philosophy

- **Actionable**: Every alert triggers clear action
- **Prioritized**: Severity defines urgency
- **Contextual**: Include links to logs/traces/runbooks
- **Precise**: Minimize false positives
- **Layered**: Multiple rules for critical detection

### 6.2 Alert Severity Levels

| Severity | Description                                | Response Time     | Notification Method    |
| -------- | ------------------------------------------ | ----------------- | ---------------------- |
| **P1**   | Service outage, data loss, security breach | Immediate (24/7)  | Call, SMS, Email, Chat |
| **P2**   | Degraded service, potential user impact    | 30 min (24/7)     | SMS, Email, Chat       |
| **P3**   | Minor issues, limited impact               | 4 business hours  | Email, Chat            |
| **P4**   | Non-urgent improvements                    | 24 business hours | Email                  |
| **Info** | Awareness only                             | N/A               | Dashboard only         |

### 6.3 Core Alert Rules

#### 6.3.1 Service Level Alerts

| Alert                 | Severity | Rule                          | Resolution Steps                    |
| --------------------- | -------- | ----------------------------- | ----------------------------------- |
| API Availability      | P1       | `success_rate < 95% for 5m`   | Check API, dependencies, infra      |
| API Latency           | P2       | `p95_latency > 500ms for 10m` | Investigate bottlenecks, scaling    |
| Vote Processing Delay | P2       | `queue_depth > 100 for 5m`    | Inspect queue, processor health     |
| Bridge Message Delays | P2       | `confirmation_time > 10m`     | Verify nodes, gas prices, contracts |
| Error Rate Elevated   | P2       | `error_rate > 1% for 5m`      | Review logs, recent deployments     |

#### 6.3.2 Infrastructure Alerts

| Alert                         | Severity | Rule                            | Resolution Steps                       |
| ----------------------------- | -------- | ------------------------------- | -------------------------------------- |
| CPU High Usage                | P3       | `cpu > 85% for 15m`             | Identify high-load processes, scale up |
| Memory High Usage             | P3       | `memory > 85% for 15m`          | Check for leaks, scale memory          |
| Disk Space Low                | P3       | `disk_free < 15%`               | Cleanup or expand storage              |
| Node Unhealthy                | P2       | `health_check_failures`         | Replace or restart node                |
| DB Connection Pool Saturation | P2       | `pool_utilization > 90% for 5m` | Increase pool size, fix leaks          |

#### 6.3.3 Business Logic Alerts

| Alert                       | Severity | Rule                          | Resolution Steps                       |
| --------------------------- | -------- | ----------------------------- | -------------------------------------- |
| Vote Failure Rate High      | P2       | `failures > 5% for 10m`       | Inspect vote processor, proof verifier |
| Proof Verification Failures | P2       | `verification_failures > 5%`  | Debug verifier, proof format           |
| Cross-Chain Bridge Failure  | P1       | `success_rate < 90% for 15m`  | Check bridge services, chain health    |
| Transaction Failure Rate    | P2       | `tx_failures > 10% for 10m`   | Review gas, network, contracts         |
| Delegation Discovery Delay  | P3       | `discovery_time > 2m for 30m` | Inspect scanner, RPC endpoints         |

### 6.4 Alert Routing and Notification

| Team                | Business Hours | After Hours | Escalation Path               |
| ------------------- | -------------- | ----------- | ----------------------------- |
| API Team            | P2+            | P1+         | Primary → Secondary → Manager |
| Infrastructure Team | P2+            | P1+         | Primary → Secondary → Manager |
| Blockchain Team     | P2+            | P1+         | Primary → Secondary → Manager |
| Database Team       | P2+            | P1+         | Primary → Secondary → Manager |
| Security Team       | P1+            | P1+         | Primary → Secondary → CISO    |

### 6.5 On-Call Procedures

- **Rotation**: Weekly rotation with handoffs
- **Schedule**: Primary & secondary on-call per team
- **Escalation**: Automated after ack timeout
- **Tooling**: PagerDuty for schedule & notification
- **Support**: Runbooks, production access, debugging tools
- **Follow-up**: Post-incident review for all P1/P2 incidents

### 6.6 Incident Management Process

1. **Detection**: Automated alert or manual report
2. **Triage**: Assess severity & impact
3. **Response**: Initial mitigation
4. **Communication**: Updates to stakeholders
5. **Resolution**: Fix root cause
6. **Post-Mortem**: Document findings & actions

#### 6.6.1 Incident Workflow

```
Detection → Triage → Response Team Assembly → Initial Assessment
        ↓
Status Communication ← Mitigation ← Root Cause Analysis
        ↓
Resolution Verification → Final Communication → Incident Documentation
        ↓
Post-Mortem Analysis → Action Items → Process Improvements
```

#### 6.6.2 Incident Severity Matrix

| Aspect               | P1 (Critical)       | P2 (High)                  | P3 (Medium)    | P4 (Low)        |
| -------------------- | ------------------- | -------------------------- | -------------- | --------------- |
| **Service Impact**   | Complete outage     | Degraded performance       | Minimal impact | No user impact  |
| **User Impact**      | >20% users affected | 5–20% affected             | <5% affected   | None            |
| **Financial Impact** | Significant         | Moderate                   | Minimal        | None            |
| **Response Team**    | All hands           | Service team + specialists | Service team   | Individual      |
| **Update Frequency** | Every 30 min        | Every 2 hours              | Daily          | Upon resolution |
| **Post-Mortem**      | Detailed required   | Required                   | Optional       | None            |

### 6.7 Incident Communication Templates

#### 6.7.1 Initial Notification

```
[P1] Incident: [Brief Title]
Status: Investigating
Start Time: [UTC time]
Services Affected: [List]
Description:
 - [Issue summary]
Impact:
 - [User/service impact]
Current Actions:
 - Investigation by [team]
 - [Mitigation steps]
Next Update By: [UTC time]
Incident Commander: [Name]
Incident Page: [Link]
```

#### 6.7.2 Update

```
[P1] Incident Update: [Brief Title]
Status: [Investigating/Mitigating/Resolved]
Current Time: [UTC time]
Services Affected: [List]
Update:
 - [New info]
Current Actions:
 - [Ongoing steps]
Next Update By: [UTC time]
Incident Commander: [Name]
Incident Page: [Link]
```

#### 6.7.3 Resolution

```
[P1] Incident Resolved: [Brief Title]
Status: Resolved
Start Time: [UTC time]
End Time: [UTC time]
Services Affected: [List]
Resolution:
 - [How resolved]
Impact Summary:
 - [Impact during incident]
Root Cause:
 - [Root cause]
Follow-up:
 - Post-mortem scheduled [date/time]
 - [Immediate actions]
Incident Commander: [Name]
Incident Page: [Link]
```

---

## 7. Dashboards and Visualization

### 7.1 Dashboard Structure

- **Executive Dashboard**: High-level health & business KPIs
- **Service Dashboards**: Deep-dive per-service metrics
- **Infrastructure Dashboards**: Node/container health
- **User Journey Dashboards**: End-to-end flows
- **Specialized Dashboards**: Security, compliance, finance

### 7.2 Standard Dashboard Components

- **Header**: Title, environment selector, time range
- **Status Summary**: Service health indicators
- **Alert Status**: Active alerts overview
- **Key Metrics**: Core metrics panels
- **Detailed Panels**: Drill-down visualizations
- **Links**: Related dashboards, runbooks, docs

### 7.3 Core Dashboards

#### 7.3.1 System Overview

| Panel          | Metrics                    | Visualization      | Purpose                    |
| -------------- | -------------------------- | ------------------ | -------------------------- |
| Service Health | Status by service          | Status grid        | At-a-glance service status |
| Error Rates    | Errors by service          | Multi-line graph   | Identify error trends      |
| Request Volume | Requests by service        | Stacked area chart | Traffic distribution       |
| Response Times | P50/P95/P99 latency        | Multi-line graph   | Performance tracking       |
| Resource Usage | CPU/memory/disk by service | Heatmap            | Bottleneck identification  |
| Alert History  | Recent alerts              | Timeline           | Incident context           |

#### 7.3.2 Vote Processing

| Panel                    | Metrics                     | Visualization     | Purpose                   |
| ------------------------ | --------------------------- | ----------------- | ------------------------- |
| Vote Throughput          | Votes processed per minute  | Line graph        | Processing capacity       |
| Vote Success Rate        | Successful vs. failed votes | Gauge + trend     | Quality indicator         |
| Processing Stages        | Time per stage              | Stacked bar chart | Bottleneck identification |
| Queue Depth              | Items in processing queue   | Line graph        | Backlog monitoring        |
| Verification Performance | Proof verification times    | Histogram         | Performance distribution  |
| Chain Distribution       | Votes by blockchain         | Pie chart         | Usage patterns            |

#### 7.3.3 Bridge Operations

| Panel                | Metrics                       | Visualization      | Purpose              |
| -------------------- | ----------------------------- | ------------------ | -------------------- |
| Message Throughput   | Messages by direction & chain | Multi-line graph   | Cross-chain activity |
| Message Success Rate | Success % by chain            | Gauge matrix       | Reliability tracking |
| Confirmation Times   | Time to confirmation by chain | Box plot           | Performance by chain |
| Gas Usage            | Gas used by operation         | Stacked bar chart  | Cost monitoring      |
| Bridge Queue         | Messages in stages            | Stacked area chart | Processing backlog   |
| Error Distribution   | Errors by type & chain        | Heatmap            | Pattern detection    |

### 7.4 User Journey Dashboards

#### 7.4.1 Vote Submission Journey

| Stage                 | Metrics                      | Indicators                    |
| --------------------- | ---------------------------- | ----------------------------- |
| UI Interaction        | Rendering time, errors       | FCP, TTI, JS errors           |
| API Submission        | Latency, validation errors   | P95 latency, status codes     |
| Proof Verification    | Verification time, failures  | Fail rate, time distribution  |
| Blockchain Submission | Tx time, block confirmations | Gas spikes, confirmation time |
| Confirmation          | End-to-end completion time   | Overall success rate          |

#### 7.4.2 Delegation Management Journey

| Stage               | Metrics                              | Indicators              |
| ------------------- | ------------------------------------ | ----------------------- |
| Delegation Creation | UI→API flow latency, creation errors | Status codes, durations |
| Discovery           | Discovery time, success rate         | Time distribution       |
| Usage               | Time to first use, usage frequency   | Usage counts            |
| Management          | Modify/revoke flows, errors          | Error events            |

### 7.5 Visualization Best Practices

- **Consistency**: Reuse chart types & color schemes
- **Context**: Show trends & baselines
- **Clarity**: Clear titles, labels, units
- **Focus**: Highlight key metrics
- **Density**: Avoid overcrowding
- **Interactivity**: Drill-down filters
- **Cross-linking**: Link related dashboards & docs

### 7.6 Dashboard Access Control

| Category         | Access Level               | Notes            |
| ---------------- | -------------------------- | ---------------- |
| Executive        | Leadership, SRE Leads      | High-level only  |
| Service Specific | Service team, SRE team     | Detailed metrics |
| User Journey     | Product & Service teams    | End-to-end flows |
| Infrastructure   | Infrastructure & SRE teams | System metrics   |
| Security         | Security team, SRE Leads   | Restricted       |

### 7.7 Dashboard Development and Governance

- **Version Control**: Dashboards as code (Git)
- **Review Process**: Peer review for changes
- **Testing**: Validate new dashboards against historical data
- **Documentation**: Embedded panel descriptions
- **Ownership**: Defined dashboard owners
- **Lifecycle**: Quarterly relevance reviews

---

## 8. Performance Monitoring

### 8.1 Performance Monitoring Strategy

Focus areas:

- **User-Perceived Performance**: RUM & synthetic tests
- **Service Performance**: Internal latency & throughput
- **Blockchain Interaction**: Confirmation times, gas metrics
- **Resource Utilization**: CPU/memory correlation
- **Degradation Detection**: Early warning alerts
- **Optimization Opportunities**: Identify hotspots

### 8.2 Key Performance Metrics

#### 8.2.1 Frontend Performance

| Metric                 | Target   | Critical Threshold |
| ---------------------- | -------- | ------------------ |
| Time to Interactive    | < 1.5 s  | > 3 s              |
| First Contentful Paint | < 1 s    | > 2.5 s            |
| Input Responsiveness   | < 100 ms | > 300 ms           |
| Total Page Load        | < 2 s    | > 5 s              |
| API Response Time      | < 300 ms | > 1 s              |
| JS Execution Time      | < 350 ms | > 750 ms           |

#### 8.2.2 API Performance

| Metric       | Target   | Critical Threshold |
| ------------ | -------- | ------------------ |
| P50 Latency  | < 100 ms | > 500 ms           |
| P95 Latency  | < 300 ms | > 1 s              |
| P99 Latency  | < 500 ms | > 2 s              |
| Error Rate   | < 0.1%   | > 1%               |
| Timeout Rate | < 0.05%  | > 0.5%             |
| Queue Time   | < 50 ms  | > 200 ms           |

#### 8.2.3 Vote Processing Performance

| Metric                  | Target   | Critical Threshold |
| ----------------------- | -------- | ------------------ |
| Submission→Chain        | < 10 s   | > 30 s             |
| Proof Verification Time | < 200 ms | > 1 s              |
| End-to-End Vote Time    | < 15 s   | > 45 s             |
| Queue Processing Rate   | > 50/min | < 10/min           |
| Processing Concurrency  | > 95%    | < 70%              |
| Database Operation Time | < 50 ms  | > 250 ms           |

#### 8.2.4 Blockchain Performance

| Metric                   | Target          | Threshold      |
| ------------------------ | --------------- | -------------- |
| Confirmation Time        | Chain-dependent | 2× normal time |
| Gas Usage Efficiency     | < 110% optimal  | > 150% optimal |
| RPC Response Time        | < 200 ms        | > 1 s          |
| Chain Interaction Errors | < 1%            | > 5%           |
| Block Finality Wait Time | Chain-dependent | 2× normal time |
| Bridge Message Time      | < 5 min         | > 15 min       |

### 8.3 Performance Testing

#### 8.3.1 Continuous Performance Testing

- **Load Tests**: Weekly (staging)
- **Stress Tests**: Monthly (staging)
- **Endurance Tests**: Quarterly (staging)
- **Spike Tests**: On-demand

#### 8.3.2 Test Types & Scenarios

| Test Type            | Description                            | Frequency | Environment |
| -------------------- | -------------------------------------- | --------- | ----------- |
| Baseline Performance | Typical load                           | Weekly    | Staging     |
| Maximum Throughput   | Load until degradation                 | Monthly   | Staging     |
| Scalability Testing  | Performance under scaled resources     | Quarterly | Staging     |
| Dependency Impact    | Simulated dependency slowdowns         | Monthly   | Staging     |
| Chain Congestion     | Normal load + slow chain confirmations | Monthly   | Test Chains |
| Cross-Chain Stress   | Heavy cross-chain usage                | On-demand | Staging     |
| Mixed Workload       | Combined operations                    | On-demand | Staging     |

### 8.4 Baselines & Regression Detection

- **Baseline**: Rolling 7-day averages
- **Regression**: Alerts on statistical anomalies vs. baseline
- **Performance Budget**: Defined limits per journey
- **Deployment Comparison**: Automated pre/post deploy tests
- **Long-term Trends**: Monthly analysis

### 8.5 Resource Utilization Correlation

Map performance to resource metrics:

- CPU saturation vs. latency
- Memory pressure vs. errors
- I/O contention vs. throughput
- DB load vs. query times
- Node health vs. chain interactions

### 8.6 Performance Issue Resolution Process

1. **Detection**: Monitoring alerts or test failures
2. **Triage**: Impact assessment & priority
3. **Diagnosis**: Root cause via logs/traces/metrics
4. **Resolution Planning**: Short- & long-term fixes
5. **Implementation**: Code/config optimization
6. **Verification**: Confirm improvements
7. **Knowledge Base**: Document issue & solution

---

## 9. Health Checks and SLOs

### 9.1 Health Check Strategy

- **Service Health**: Availability & functionality
- **Dependency Health**: External system checks
- **E2E Health**: Synthetic user transactions
- **Resource Health**: Infra & platform status
- **Security Health**: Control effectiveness

### 9.2 Health Check Implementation

#### 9.2.1 Service Health Checks

| Service         | Check Type        | Frequency | Timeout | Success Criteria          |
| --------------- | ----------------- | --------- | ------- | ------------------------- |
| API Services    | HTTP endpoint     | 15s       | 3s      | 200 OK + schema match     |
| Vote Processor  | Functional        | 30s       | 5s      | Sample vote processed     |
| Bridge Services | Connectivity      | 60s       | 10s     | Connected to all chains   |
| Database        | Query             | 30s       | 3s      | SELECT 1 returns result   |
| Cache           | Read/write        | 30s       | 2s      | Write & read success      |
| Message Queue   | Producer/consumer | 30s       | 3s      | Message roundtrip success |

#### 9.2.2 End-to-End Health Checks

| Journey             | Check Type            | Frequency | Timeout | Success Criteria             |
| ------------------- | --------------------- | --------- | ------- | ---------------------------- |
| Vote Submission     | Synthetic vote tx     | 5m        | 30s     | End-to-end flow completes    |
| Delegation Creation | Synthetic delegation  | 5m        | 30s     | Delegation successful        |
| Cross-Chain Voting  | Synthetic cross-chain | 15m       | 5m      | Confirmation on target chain |
| User Authentication | Synthetic login       | 5m        | 10s     | Login flow completes         |
| Proof Verification  | Known-proof check     | 5m        | 15s     | Verification succeeds        |

#### 9.2.3 Dependency Health Checks

| Dependency       | Check Type            | Frequency | Timeout | Success Criteria          |
| ---------------- | --------------------- | --------- | ------- | ------------------------- |
| Blockchain Nodes | RPC health            | 1m        | 5s      | Response within tolerance |
| External APIs    | Endpoint availability | 5m        | 3s      | Valid response            |
| Cloud Services   | Service-specific      | 5m        | 10s     | Healthy status            |
| DNS Resolution   | DNS lookup            | 5m        | 2s      | Successful resolution     |
| CDN Content      | Content retrieval     | 5m        | 3s      | Content served            |

### 9.3 Health Status Reporting

- **Internal Dashboard**: Live health status
- **Status Page**: Public-facing overview
- **API Endpoint**: Machine-readable health JSON
- **Notifications**: Alerts on health state changes
- **Historical Status**: Uptime & incident history

### 9.4 Service Level Objectives (SLOs)

#### 9.4.1 Availability SLOs

| Service           | SLO    | Measurement           | Exclusions            |
| ----------------- | ------ | --------------------- | --------------------- |
| API Services      | 99.95% | Successful request %  | Planned maintenance   |
| Vote Processing   | 99.9%  | Successful vote %     | Chain outages         |
| Bridge Operations | 99.5%  | Successful message %  | External chain issues |
| Frontend          | 99.95% | Successful page loads | Client-side issues    |
| Overall System    | 99.9%  | Weighted composite    | Documented exclusions |

#### 9.4.2 Latency SLOs

| Service              | SLO        | Measurement             | Threshold  |
| -------------------- | ---------- | ----------------------- | ---------- |
| API Response Time    | 99% <300ms | Server-side P99 latency | P99 <300ms |
| Vote Processing Time | 99% <15s   | End-to-end P99          | P99 <15s   |
| Bridge Confirmation  | 95% <10m   | End-to-end P95          | P95 <10m   |
| Page Load Time       | 95% <3s    | RUM P95                 | P95 <3s    |
| Proof Verification   | 99% <1s    | Server-side P99         | P99 <1s    |

#### 9.4.3 Quality SLOs

| Service                  | SLO    | Measurement                       | Error Budget |
| ------------------------ | ------ | --------------------------------- | ------------ |
| Vote Success Rate        | 99.9%  | Successful votes / total attempts | 0.1%         |
| Delegation Success Rate  | 99.9%  | Successful delegations / attempts | 0.1%         |
| Data Consistency         | 99.99% | Validation checks pass            | 0.01%        |
| Transaction Success Rate | 99.5%  | Successful on-chain txs           | 0.5%         |
| Auth Success Rate        | 99.95% | Successful logins / attempts      | 0.05%        |

### 9.5 Error Budget Management

- **Budget Calculation**:  
  Error Budget = (1 – SLO target) × Total time in period (e.g., month).
- **Monitoring**:  
  Dashboards track budget burn rate vs. usage.
- **Policy**:
  - If > 50% burned halfway through period → freeze non-critical releases
  - If budget reaches 100% → immediate mitigation & release pause
- **Review**:  
  Monthly error budget review as part of SRE QBR.

---

## 10. Troubleshooting Guide

### 10.1 Common Issues & First Steps

1. **High Latency**

   - Check metrics dashboard (p95/p99)
   - Inspect service-level traces for bottlenecks
   - Review recent deployments or config changes

2. **Increased Error Rate**

   - Examine logs for ERROR/FATAL entries
   - Correlate trace IDs for failing requests
   - Verify dependency health (DB, external APIs, chain nodes)

3. **Missing Logs or Metrics**

   - Confirm agent health and connectivity
   - Review log shipping (Fluentd/Vector) and metric exporters
   - Check storage back-pressure or retention policies

4. **Tracing Gaps**
   - Ensure services propagate `traceparent` header
   - Validate OpenTelemetry collector sampling rules
   - Check span attribute filters and privacy redaction

### 10.2 Step-by-Step Troubleshooting Workflow

1. **Identify**: Gather evidence (alerts, dashboards, logs)
2. **Contain**: Mitigate user impact (scale up, rollback)
3. **Diagnose**:
   - Correlate alerts → logs → traces
   - Use full-trace view to pinpoint failing component
4. **Resolve**:
   - Apply hotfix or configuration update
   - Scale resources if needed
5. **Verify**:
   - Confirm service health & metrics return to normal
6. **Document**:
   - Update runbook with discovered root cause & fix

### 10.3 Runbook Links

- [Vote Service Runbook](https://…/vote-runbook)
- [Bridge Operations Runbook](https://…/bridge-runbook)
- [Platform Scaling Guide](https://…/scaling-guide)

---

## 11. Continuous Improvement

1. **Quarterly Observability Reviews**

   - Assess tooling, coverage gaps, cost optimization
   - Update sampling policies and retention strategies

2. **Post-Mortem Integration**

   - Extract action items from incident reviews
   - Prioritize observability enhancements

3. **Tooling Upgrades**

   - Evaluate new versions (OpenTelemetry, Grafana)
   - Pilot in staging before production rollout

4. **Training & Documentation**

   - Regular SRE & DevTeam observability workshops
   - Maintain up-to-date runbooks & runbook exercises

5. **Feedback Loop**
   - Solicit developer & operator feedback
   - Incorporate suggestions into roadmap

---

## 12. Appendices

### Appendix A – Glossary

- **SLO**: Service Level Objective
- **SLI**: Service Level Indicator
- **ILM**: Index Lifecycle Management
- **RUM**: Real User Monitoring

### Appendix B – Reference Architectures

- **ELK Stack** for log analytics
- **Prometheus + Thanos** for scalable metrics
- **OpenTelemetry + Jaeger** for distributed tracing

---
