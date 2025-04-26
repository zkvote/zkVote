# zkVote: CI/CD Pipeline Guide

**Document ID:** ZKV-CICD-2025-001  
**Version:** 1.0  
**Date:** 2025-04-24  
**Author:** Cass402  
**Classification:** Internal

## Document Control

| Version | Date       | Author  | Description of Changes |
| ------- | ---------- | ------- | ---------------------- |
| 1.0     | 2025-04-24 | Cass402 | Initial version        |

## Table of Contents

1. [Introduction](#1-introduction)
2. [CI/CD Strategy Overview](#2-cicd-strategy-overview)
3. [GitHub Actions Configuration](#3-github-actions-configuration)
4. [Pipeline Components](#4-pipeline-components)
5. [Smart Contract CI/CD](#5-smart-contract-cicd)
6. [Frontend CI/CD](#6-frontend-cicd)
7. [Backend & API CI/CD](#7-backend--api-cicd)
8. [Cross-Chain Bridge CI/CD](#8-cross-chain-bridge-cicd)
9. [Security Testing Pipeline](#9-security-testing-pipeline)
10. [Deployment Workflows](#10-deployment-workflows)
11. [Monitoring and Alerting](#11-monitoring-and-alerting)
12. [Maintenance and Troubleshooting](#12-maintenance-and-troubleshooting)
13. [Appendices](#13-appendices)

## 1. Introduction

### 1.1 Purpose

This guide documents the Continuous Integration and Continuous Deployment (CI/CD) pipeline for the zkVote protocol. It provides detailed instructions for setting up, maintaining, and troubleshooting the automated build, test, and deployment processes using GitHub Actions.

### 1.2 Scope

This document covers:

- CI/CD strategy and philosophy
- GitHub Actions workflows configuration
- Component-specific pipeline configurations
- Testing methodologies within the pipeline
- Secure deployment processes
- Monitoring and maintenance

### 1.3 Audience

This guide is intended for:

- Development team members
- DevOps engineers
- QA engineers
- Project maintainers
- Security team members
- Contributors to the zkVote project

### 1.4 Related Documents

- zkVote Development Handbook (ZKV-DEV-2025-001)
- zkVote Security Protocols (ZKV-SEC-2025-002)
- Smart Contract Testing Guide (ZKV-TEST-2025-001)
- Deployment Strategy Document (ZKV-DEPL-2025-001)

## 2. CI/CD Strategy Overview

### 2.1 Core Principles

The zkVote CI/CD pipeline is built on the following principles:

1. **Security First**: Pipeline includes comprehensive security testing at every stage
2. **Automation**: Minimize manual interventions to reduce human error
3. **Reliability**: Consistent, repeatable builds and deployments
4. **Efficiency**: Fast feedback loops for developers
5. **Environment Parity**: Test environments closely match production
6. **Comprehensive Testing**: Multiple test types across all components
7. **Observability**: Complete visibility into pipeline execution

### 2.2 Workflow Overview

![CI/CD Workflow Overview](https://placeholder.com/zkvote-cicd-workflow)

Our CI/CD workflow follows these stages:

1. **Code Integration**: Triggered on pull requests and pushes to protected branches
2. **Build**: Compile and build project components
3. **Unit Testing**: Run unit tests for all components
4. **Integration Testing**: Test component interactions
5. **Security Scanning**: Static analysis and vulnerability scanning
6. **Performance Testing**: Test critical performance metrics
7. **Staging Deployment**: Deploy to staging environment
8. **E2E Testing**: Run end-to-end tests in staging
9. **Production Deployment**: Deploy to production environment
10. **Post-deployment Verification**: Verify successful deployment

### 2.3 Branch Strategy

zkVote follows a trunk-based development model with short-lived feature branches:

| Branch Type     | Naming Convention        | Purpose             | CI/CD Behavior                             |
| --------------- | ------------------------ | ------------------- | ------------------------------------------ |
| **Main**        | `main`                   | Production code     | Full pipeline including deployment         |
| **Development** | `dev`                    | Integration branch  | Full pipeline up to staging deployment     |
| **Feature**     | `feature/[feature-name]` | Feature development | Build and test stages                      |
| **Hotfix**      | `hotfix/[issue-name]`    | Critical fixes      | Expedited pipeline with security gates     |
| **Release**     | `release/v[x.y.z]`       | Release preparation | Full pipeline with additional verification |

### 2.4 Environment Strategy

| Environment     | Purpose                   | Deployment Frequency              | Access Control           |
| --------------- | ------------------------- | --------------------------------- | ------------------------ |
| **Development** | Developer testing         | Automatic on merge to `dev`       | Development team         |
| **Staging**     | Pre-production validation | Automatic on successful dev tests | All internal teams       |
| **Production**  | Live system               | Manual approval after staging     | Restricted team members  |
| **Preview**     | PR previews               | Automatic on PR                   | Developers and reviewers |
| **Security**    | Isolated security testing | Scheduled and on-demand           | Security team            |

## 3. GitHub Actions Configuration

### 3.1 Repository Setup

Ensure your repository has the following structure for GitHub Actions:

```
.github/
├── workflows/
│   ├── smart-contracts.yml
│   ├── frontend.yml
│   ├── backend.yml
│   ├── bridge.yml
│   ├── security.yml
│   └── deployment.yml
├── actions/
│   ├── setup-zkp-environment/
│   │   └── action.yml
│   └── solidity-security-check/
│       └── action.yml
└── CODEOWNERS
```

### 3.2 Environment Configuration

Set up the following environments in GitHub repository settings:

1. **Navigate to**: Repository → Settings → Environments
2. **Create environments**:
   - `development`
   - `staging`
   - `production`
3. **Configure environment protection rules**:
   - Required reviewers for production
   - Deployment branch restrictions
   - Wait timers for production

### 3.3 Secrets Management

Store sensitive information in GitHub Secrets:

1. **Repository secrets** (for all workflows):

   - `INFURA_API_KEY`
   - `ALCHEMY_API_KEY`
   - `NPM_TOKEN`

2. **Environment secrets** (environment-specific):
   - `STAGING_PRIVATE_KEY`
   - `PRODUCTION_PRIVATE_KEY`
   - `DEPLOYMENT_WEBHOOK_URL`

### 3.4 GitHub Actions Workflow Basics

All zkVote workflows follow this general structure:

```yaml
name: Workflow Name

on:
  push:
    branches: [main, dev]
    paths:
      - "relevant/path/**"
  pull_request:
    branches: [main, dev]
    paths:
      - "relevant/path/**"

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      # Additional steps...

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      # Testing steps...

  security:
    needs: test
    runs-on: ubuntu-latest
    steps:
      # Security scanning steps...

  deploy:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    needs: [test, security]
    runs-on: ubuntu-latest
    environment: production
    steps:
      # Deployment steps...
```

## 4. Pipeline Components

### 4.1 Common Components

The following components are shared across multiple workflows:

#### 4.1.1 Caching

```yaml
- name: Cache dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.npm
      node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

#### 4.1.2 Notification Actions

```yaml
- name: Notify Slack on failure
  if: failure()
  uses: slackapi/slack-github-action@v1.24.0
  with:
    payload: |
      {
        "text": "❌ CI Pipeline Failed in ${{ github.repository }}",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "❌ CI Pipeline Failed in ${{ github.repository }}\n*Workflow:* ${{ github.workflow }}\n*Branch:* ${{ github.ref_name }}"
            }
          },
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "<${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}|View workflow run>"
            }
          }
        ]
      }
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
    SLACK_WEBHOOK_TYPE: INCOMING_WEBHOOK
```

#### 4.1.3 Artifact Sharing

```yaml
- name: Upload artifacts
  uses: actions/upload-artifact@v3
  with:
    name: build-artifacts
    path: |
      dist/
      build/
      coverage/
    retention-days: 7
```

### 4.2 Testing Components

#### 4.2.1 Code Linting

```yaml
- name: Lint code
  run: |
    npm run lint
    npm run prettier:check
```

#### 4.2.2 Unit Testing

```yaml
- name: Run unit tests
  run: npm run test:unit
  env:
    NODE_OPTIONS: --max-old-space-size=4096
```

#### 4.2.3 Coverage Reporting

```yaml
- name: Generate coverage report
  run: npm run test:coverage

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    token: ${{ secrets.CODECOV_TOKEN }}
    directory: ./coverage
    flags: unittests
    name: codecov-umbrella
    fail_ci_if_error: true
```

## 5. Smart Contract CI/CD

### 5.1 Smart Contract Workflow

Create `.github/workflows/smart-contracts.yml`:

```yaml
name: Smart Contract CI/CD

on:
  push:
    branches: [main, dev]
    paths:
      - "contracts/**"
      - "test/**"
      - "hardhat.config.js"
  pull_request:
    branches: [main, dev]
    paths:
      - "contracts/**"
      - "test/**"
      - "hardhat.config.js"

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Compile contracts
        run: npx hardhat compile

      - name: Cache compiled contracts
        uses: actions/cache@v3
        with:
          path: artifacts/
          key: ${{ runner.os }}-artifacts-${{ github.sha }}

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Restore compiled contracts
        uses: actions/cache@v3
        with:
          path: artifacts/
          key: ${{ runner.os }}-artifacts-${{ github.sha }}

      - name: Run contract tests
        run: npx hardhat test
        env:
          REPORT_GAS: true

      - name: Generate coverage report
        run: npx hardhat coverage

      - name: Upload coverage report
        uses: actions/upload-artifact@v3
        with:
          name: coverage-report
          path: coverage/
          retention-days: 14

  security:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run Slither
        uses: crytic/slither-action@v0.3.0
        with:
          target: contracts/
          slither-args: '--filter-paths "node_modules/*" --exclude naming-convention,external-function'

      - name: Run Mythril
        run: |
          pip3 install mythril
          myth analyze contracts/*.sol --solc-json hardhat.config.js

      - name: Check for dependency vulnerabilities
        run: npm audit --audit-level=high
        continue-on-error: true

  deploy-testnet:
    if: github.ref == 'refs/heads/dev'
    needs: [test, security]
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Deploy to testnet
        run: npx hardhat run scripts/deploy.js --network sepolia
        env:
          PRIVATE_KEY: ${{ secrets.STAGING_PRIVATE_KEY }}
          INFURA_API_KEY: ${{ secrets.INFURA_API_KEY }}

      - name: Save deployment info
        run: |
          mkdir -p deployment
          cat artifacts/deployment.json > deployment/testnet-deployment.json

      - name: Upload deployment artifacts
        uses: actions/upload-artifact@v3
        with:
          name: testnet-deployment
          path: deployment/
          retention-days: 30

  deploy-mainnet:
    if: github.ref == 'refs/heads/main'
    needs: [test, security]
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Deploy to mainnet
        run: npx hardhat run scripts/deploy.js --network mainnet
        env:
          PRIVATE_KEY: ${{ secrets.PRODUCTION_PRIVATE_KEY }}
          INFURA_API_KEY: ${{ secrets.INFURA_API_KEY }}

      - name: Verify contracts
        run: npx hardhat verify-contracts --network mainnet
        env:
          ETHERSCAN_API_KEY: ${{ secrets.ETHERSCAN_API_KEY }}

      - name: Save deployment info
        run: |
          mkdir -p deployment
          cat artifacts/deployment.json > deployment/mainnet-deployment.json

      - name: Upload deployment artifacts
        uses: actions/upload-artifact@v3
        with:
          name: mainnet-deployment
          path: deployment/
          retention-days: 90
```

### 5.2 Circuit Testing Configuration

Create a specialized workflow for testing zero-knowledge circuits:

```yaml
name: ZK Circuit Testing

on:
  push:
    branches: [main, dev]
    paths:
      - "circuits/**"
  pull_request:
    branches: [main, dev]
    paths:
      - "circuits/**"

jobs:
  compile-circuits:
    runs-on: ubuntu-latest
    container:
      image: hermeznetwork/circom:2.1.4
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Install dependencies
        run: npm ci

      - name: Compile circuits
        run: |
          mkdir -p build/circuits
          for circuit in circuits/*.circom; do
            circom $circuit --r1cs --wasm -o build/circuits
          done

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: compiled-circuits
          path: build/circuits/
          retention-days: 7

  test-circuits:
    needs: compile-circuits
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Download compiled circuits
        uses: actions/download-artifact@v3
        with:
          name: compiled-circuits
          path: build/circuits/

      - name: Run circuit tests
        run: npm run test:circuits
```

## 6. Frontend CI/CD

### 6.1 Frontend Workflow

Create `.github/workflows/frontend.yml`:

```yaml
name: Frontend CI/CD

on:
  push:
    branches: [main, dev]
    paths:
      - "frontend/**"
      - "sdk/**"
  pull_request:
    branches: [main, dev]
    paths:
      - "frontend/**"
      - "sdk/**"

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./frontend
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"
          cache-dependency-path: frontend/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Build SDK
        working-directory: ./sdk
        run: |
          npm ci
          npm run build
          npm link

      - name: Link SDK to frontend
        run: npm link @zkvote/sdk

      - name: Build frontend
        run: npm run build

      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: frontend-build
          path: frontend/dist/
          retention-days: 7

  test:
    needs: build
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./frontend
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"
          cache-dependency-path: frontend/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Build and link SDK
        working-directory: ./sdk
        run: |
          npm ci
          npm run build
          npm link

      - name: Link SDK to frontend
        run: npm link @zkvote/sdk

      - name: Lint code
        run: npm run lint

      - name: Run unit tests
        run: npm run test:unit

      - name: Run component tests
        run: npm run test:components

      - name: Upload test results
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: frontend/coverage/
          retention-days: 7

  security:
    needs: test
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./frontend
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"
          cache-dependency-path: frontend/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Run dependency audit
        run: npm audit --audit-level=high
        continue-on-error: true

      - name: Run SAST scan
        uses: microsoft/eslint-formatter-sarif@v2
        with:
          eslint-args: '--config ./frontend/.eslintrc.js "./frontend/src/**/*.{js,ts,tsx}"'

  deploy-preview:
    if: github.event_name == 'pull_request'
    needs: [test, security]
    runs-on: ubuntu-latest
    environment: preview
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          name: frontend-build
          path: frontend/dist/

      - name: Deploy to preview
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: "${{ secrets.GITHUB_TOKEN }}"
          firebaseServiceAccount: "${{ secrets.FIREBASE_SERVICE_ACCOUNT }}"
          projectId: zkvote-dev
          channelId: "pr-${{ github.event.number }}"
          entryPoint: ./frontend

  deploy-staging:
    if: github.ref == 'refs/heads/dev'
    needs: [test, security]
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          name: frontend-build
          path: frontend/dist/

      - name: Deploy to staging
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: "${{ secrets.GITHUB_TOKEN }}"
          firebaseServiceAccount: "${{ secrets.FIREBASE_SERVICE_ACCOUNT }}"
          projectId: zkvote-dev
          channelId: staging
          entryPoint: ./frontend

  deploy-production:
    if: github.ref == 'refs/heads/main'
    needs: [test, security]
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          name: frontend-build
          path: frontend/dist/

      - name: Deploy to production
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: "${{ secrets.GITHUB_TOKEN }}"
          firebaseServiceAccount: "${{ secrets.FIREBASE_SERVICE_ACCOUNT_PROD }}"
          projectId: zkvote-prod
          channelId: live
          entryPoint: ./frontend
```

## 7. Backend & API CI/CD

### 7.1 Backend Workflow

Create `.github/workflows/backend.yml`:

```yaml
name: Backend & API CI/CD

on:
  push:
    branches: [main, dev]
    paths:
      - "backend/**"
      - "api/**"
  pull_request:
    branches: [main, dev]
    paths:
      - "backend/**"
      - "api/**"

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./backend
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"
          cache-dependency-path: backend/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Build backend
        run: npm run build

      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: backend-build
          path: backend/dist/
          retention-days: 7

  test:
    needs: build
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./backend
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: zkvote_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:6
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"
          cache-dependency-path: backend/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Run migrations
        run: npm run db:migrate
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/zkvote_test

      - name: Run unit tests
        run: npm run test:unit
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/zkvote_test
          REDIS_URL: redis://localhost:6379

      - name: Run API integration tests
        run: npm run test:api
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/zkvote_test
          REDIS_URL: redis://localhost:6379
          TEST_MODE: true

      - name: Generate coverage report
        run: npm run test:coverage
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/zkvote_test
          REDIS_URL: redis://localhost:6379

      - name: Upload test results
        uses: actions/upload-artifact@v3
        with:
          name: backend-test-results
          path: backend/coverage/
          retention-days: 7

  security:
    needs: test
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./backend
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"
          cache-dependency-path: backend/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Run dependency audit
        run: npm audit --audit-level=high
        continue-on-error: true

      - name: Run SAST scan
        uses: snyk/actions/node@master
        with:
          args: --severity-threshold=high --sarif-file-output=snyk-backend.sarif ./backend
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

      - name: Upload SARIF file
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: snyk-backend.sarif
          category: backend-snyk

  deploy-staging:
    if: github.ref == 'refs/heads/dev'
    needs: [test, security]
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          name: backend-build
          path: backend/dist/

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: ./backend
          push: true
          tags: ghcr.io/${{ github.repository }}/backend:staging

      - name: Deploy to staging
        uses: digitalocean/action-doctl@v2
        with:
          token: ${{ secrets.DIGITALOCEAN_TOKEN }}
          args: kubernetes cluster kubeconfig show zkvote-staging > $GITHUB_WORKSPACE/kubeconfig.yml

      - name: Deploy to Kubernetes
        run: |
          export KUBECONFIG=$GITHUB_WORKSPACE/kubeconfig.yml
          kubectl apply -f k8s/staging/backend-deployment.yml
          kubectl rollout restart deployment/zkvote-backend -n zkvote-staging

  deploy-production:
    if: github.ref == 'refs/heads/main'
    needs: [test, security]
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          name: backend-build
          path: backend/dist/

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: ./backend
          push: true
          tags: |
            ghcr.io/${{ github.repository }}/backend:production
            ghcr.io/${{ github.repository }}/backend:${{ github.sha }}

      - name: Deploy to production
        uses: digitalocean/action-doctl@v2
        with:
          token: ${{ secrets.DIGITALOCEAN_TOKEN }}
          args: kubernetes cluster kubeconfig show zkvote-production > $GITHUB_WORKSPACE/kubeconfig.yml

      - name: Deploy to Kubernetes
        run: |
          export KUBECONFIG=$GITHUB_WORKSPACE/kubeconfig.yml
          kubectl apply -f k8s/production/backend-deployment.yml
          kubectl rollout restart deployment/zkvote-backend -n zkvote-production
```

## 8. Cross-Chain Bridge CI/CD

### 8.1 Bridge Workflow

Create `.github/workflows/bridge.yml`:

```yaml
name: Cross-Chain Bridge CI/CD

on:
  push:
    branches: [main, dev]
    paths:
      - "bridge/**"
  pull_request:
    branches: [main, dev]
    paths:
      - "bridge/**"

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./bridge
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"
          cache-dependency-path: bridge/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Build bridge
        run: npm run build

      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: bridge-build
          path: bridge/dist/
          retention-days: 7

  test:
    needs: build
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./bridge
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"
          cache-dependency-path: bridge/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests
        run: npm run test:unit

      - name: Start local blockchains
        run: npm run start:chains

      - name: Run integration tests
        run: npm run test:integration

      - name: Run cross-chain tests
        run: npm run test:cross-chain

      - name: Upload test results
        uses: actions/upload-artifact@v3
        with:
          name: bridge-test-results
          path: bridge/coverage/
          retention-days: 7

  security:
    needs: test
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./bridge
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"
          cache-dependency-path: bridge/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Run security audit
        run: npm audit --audit-level=high
        continue-on-error: true

      - name: Run bridge contract audit
        working-directory: ./bridge/contracts
        run: |
          npm install -g eth-security-toolbox
          slither . --filter-paths "node_modules/" --exclude naming-convention

  deploy-staging:
    if: github.ref == 'refs/heads/dev'
    needs: [test, security]
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          name: bridge-build
          path: bridge/dist/

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: ./bridge
          push: true
          tags: ghcr.io/${{ github.repository }}/bridge:staging

      - name: Deploy to staging
        uses: digitalocean/action-doctl@v2
        with:
          token: ${{ secrets.DIGITALOCEAN_TOKEN }}
          args: kubernetes cluster kubeconfig show zkvote-staging > $GITHUB_WORKSPACE/kubeconfig.yml

      - name: Deploy to Kubernetes
        run: |
          export KUBECONFIG=$GITHUB_WORKSPACE/kubeconfig.yml
          kubectl apply -f k8s/staging/bridge-deployment.yml
          kubectl rollout restart deployment/zkvote-bridge -n zkvote-staging

  deploy-production:
    if: github.ref == 'refs/heads/main'
    needs: [test, security]
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          name: bridge-build
          path: bridge/dist/

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: ./bridge
          push: true
          tags: |
            ghcr.io/${{ github.repository }}/bridge:production
            ghcr.io/${{ github.repository }}/bridge:${{ github.sha }}

      - name: Deploy to production
        uses: digitalocean/action-doctl@v2
        with:
          token: ${{ secrets.DIGITALOCEAN_TOKEN }}
          args: kubernetes cluster kubeconfig show zkvote-production > $GITHUB_WORKSPACE/kubeconfig.yml

      - name: Deploy to Kubernetes
        run: |
          export KUBECONFIG=$GITHUB_WORKSPACE/kubeconfig.yml
          kubectl apply -f k8s/production/bridge-deployment.yml
          kubectl rollout restart deployment/zkvote-bridge -n zkvote-production
```

## 9. Security Testing Pipeline

### 9.1 Security Workflow

Create `.github/workflows/security.yml`:

```yaml
name: Security Testing

on:
  schedule:
    - cron: "0 0 * * *" # Run daily at midnight
  workflow_dispatch: # Allow manual triggering

jobs:
  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"

      - name: Check frontend dependencies
        working-directory: ./frontend
        run: |
          npm ci
          npm audit --audit-level=moderate
        continue-on-error: true

      - name: Check backend dependencies
        working-directory: ./backend
        run: |
          npm ci
          npm audit --audit-level=moderate
        continue-on-error: true

      - name: Check contract dependencies
        working-directory: ./contracts
        run: |
          npm ci
          npm audit --audit-level=high
        continue-on-error: true

      - name: Generate dependency report
        run: |
          echo "# Dependency Security Report" > dependency-report.md
          echo "## Frontend" >> dependency-report.md
          cd frontend && npm audit --json | npx -y npm-audit-markdown >> ../dependency-report.md || true
          echo "## Backend" >> dependency-report.md
          cd ../backend && npm audit --json | npx -y npm-audit-markdown >> ../dependency-report.md || true
          echo "## Contracts" >> dependency-report.md
          cd ../contracts && npm audit --json | npx -y npm-audit-markdown >> ../dependency-report.md || true

      - name: Upload dependency report
        uses: actions/upload-artifact@v3
        with:
          name: dependency-report
          path: dependency-report.md
          retention-days: 30

  static-analysis:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"

      - name: Run CodeQL analysis
        uses: github/codeql-action/init@v2
        with:
          languages: javascript, typescript

      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v2

      - name: Contract security analysis
        working-directory: ./contracts
        run: |
          npm ci
          npx hardhat compile
          npm install -g eth-security-toolbox
          slither . --filter-paths "node_modules/" --json slither-output.json

      - name: Upload slither results
        uses: actions/upload-artifact@v3
        with:
          name: slither-output
          path: contracts/slither-output.json
          retention-days: 30

  penetration-testing:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup environment
        run: |
          docker-compose -f docker-compose.security.yml up -d
          sleep 30  # Wait for services to start

      - name: Run OWASP ZAP scan
        uses: zaproxy/action-full-scan@v0.4.0
        with:
          target: "http://localhost:3000"
          rules_file_name: ".zap/rules.tsv"
          cmd_options: "-a"

      - name: Run API security tests
        run: |
          npm install -g dredd
          dredd ./api/openapi.yaml http://localhost:3001 --hookfiles=./api/dredd-hooks.js

      - name: Generate security report
        run: |
          echo "# Security Testing Report" > security-report.md
          echo "## OWASP ZAP Scan Results" >> security-report.md
          cat zap-report.md >> security-report.md
          echo "## API Security Test Results" >> security-report.md
          cat dredd-output.md >> security-report.md

      - name: Upload security report
        uses: actions/upload-artifact@v3
        with:
          name: security-report
          path: security-report.md
          retention-days: 30

      - name: Cleanup environment
        run: docker-compose -f docker-compose.security.yml down

  security-notification:
    needs: [dependency-scan, static-analysis, penetration-testing]
    runs-on: ubuntu-latest
    if: always()
    steps:
      - name: Download dependency report
        uses: actions/download-artifact@v3
        with:
          name: dependency-report

      - name: Download security report
        uses: actions/download-artifact@v3
        with:
          name: security-report

      - name: Process security reports
        run: |
          cat dependency-report.md security-report.md > full-security-report.md
          # Check for high severity issues
          if grep -q "High" full-security-report.md; then
            echo "HIGH_SEVERITY_ISSUES=true" >> $GITHUB_ENV
          else
            echo "HIGH_SEVERITY_ISSUES=false" >> $GITHUB_ENV
          fi

      - name: Create GitHub issue for high severity
        if: env.HIGH_SEVERITY_ISSUES == 'true'
        uses: JasonEtco/create-an-issue@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          filename: .github/SECURITY_ISSUE_TEMPLATE.md
          update_existing: true

      - name: Notify security team
        if: env.HIGH_SEVERITY_ISSUES == 'true'
        uses: slackapi/slack-github-action@v1.24.0
        with:
          payload: |
            {
              "text": "⚠️ High severity security issues found in zkVote",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "⚠️ *High severity security issues detected in zkVote security scan*\n*Repository:* ${{ github.repository }}\n*Scan Date:* ${{ github.event.repository.updated_at }}"
                  }
                },
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "Please review the security reports and take appropriate action."
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SECURITY_SLACK_WEBHOOK_URL }}
          SLACK_WEBHOOK_TYPE: INCOMING_WEBHOOK
```

## 10. Deployment Workflows

### 10.1 Full System Deployment

Create `.github/workflows/full-deployment.yml`:

```yaml
name: Full System Deployment

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production
      components:
        description: 'Components to deploy'
        required: true
        default: 'all'
        type: choice
        options:
          - all
          - contracts
          - frontend
          - backend
          - bridge

jobs:
  prepare:
    runs-on: ubuntu-latest
    outputs:
      deploy_contracts: ${{ steps.check-components.outputs.deploy_contracts }}
      deploy_frontend: ${{ steps.check-components.outputs.deploy_frontend }}
      deploy_backend: ${{ steps.check-components.outputs.deploy_backend }}
      deploy_bridge: ${{ steps.check-components.outputs.deploy_bridge }}
      environment: ${{ github.event.inputs.environment }}
    steps:
      - name: Check components to deploy
        id: check-components
        run: |
          if [[ "${{ github.event.inputs.components }}" == "all" || "${{ github.event.inputs.components }}" == "contracts" ]]; then
            echo "deploy_contracts=true" >> $GITHUB_OUTPUT
          else
            echo "deploy_contracts=false" >> $GITHUB_OUTPUT
          fi

          if [[ "${{ github.event.inputs.components }}" == "all" || "${{ github.event.inputs.components }}" == "frontend" ]]; then
            echo "deploy_frontend=true" >> $GITHUB_OUTPUT
          else
            echo "deploy_frontend=false" >> $GITHUB_OUTPUT
          fi

          if [[ "${{ github.event.inputs.components }}" == "all" || "${{ github.event.inputs.components }}" == "backend" ]]; then
            echo "deploy_backend=true" >> $GITHUB_OUTPUT
          else
            echo "deploy_backend=false" >> $GITHUB_OUTPUT
          fi

          if [[ "${{ github.event.inputs.components }}" == "all" || "${{ github.event.inputs.components }}" == "bridge" ]]; then
            echo "deploy_bridge=true" >> $GITHUB_OUTPUT
          else
            echo "deploy_bridge=false" >> $GITHUB_OUTPUT
          fi

      - name: Validate environment
        run: |
          if [[ "${{ github.event.inputs.environment }}" != "staging" && "${{ github.event.inputs.environment }}" != "production" ]]; then
            echo "Invalid environment specified: ${{ github.event.inputs.environment }}"
            exit 1
          fi

  deploy-contracts:
    needs: prepare
    if: needs.prepare.outputs.deploy_contracts == 'true'
    runs-on: ubuntu-latest
    environment: ${{ needs.prepare.outputs.environment }}
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        working-directory: ./contracts
        run: npm ci

      - name: Compile contracts
        working-directory: ./contracts
        run: npx hardhat compile

      - name: Deploy contracts
        working-directory: ./contracts
        run: |
          if [[ "${{ needs.prepare.outputs.environment }}" == "production" ]]; then
            npx hardhat run scripts/deploy.js --network mainnet
          else
            npx hardhat run scripts/deploy.js --network sepolia
          fi
        env:
          PRIVATE_KEY: ${{ secrets.DEPLOY_PRIVATE_KEY }}
          INFURA_API_KEY: ${{ secrets.INFURA_API_KEY }}

      - name: Upload deployment artifacts
        uses: actions/upload-artifact@v3
        with:
          name: contract-deployment
          path: contracts/deployments/
          retention-days: 90

  deploy-frontend:
    needs: [prepare, deploy-contracts]
    if: |
      needs.prepare.outputs.deploy_frontend == 'true' &&
      (needs.prepare.outputs.deploy_contracts == 'false' || success())
    runs-on: ubuntu-latest
    environment: ${{ needs.prepare.outputs.environment }}
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Download contract deployments
        if: needs.prepare.outputs.deploy_contracts == 'true'
        uses: actions/download-artifact@v3
        with:
          name: contract-deployment
          path: contracts/deployments/

      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci

      - name: Generate contract types
        if: needs.prepare.outputs.deploy_contracts == 'true'
        working-directory: ./contracts
        run: |
          npm ci
          npm run generate-types

      - name: Copy contract types to frontend
        if: needs.prepare.outputs.deploy_contracts == 'true'
        run: |
          mkdir -p frontend/src/types/contracts
          cp -r contracts/typechain-types/* frontend/src/types/contracts/

      - name: Build frontend
        working-directory: ./frontend
        run: |
          if [[ "${{ needs.prepare.outputs.environment }}" == "production" ]]; then
            npm run build:prod
          else
            npm run build:staging
          fi

      - name: Deploy frontend
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ needs.prepare.outputs.environment == 'production' && secrets.FIREBASE_SERVICE_ACCOUNT_PROD || secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: ${{ needs.prepare.outputs.environment == 'production' && 'zkvote-prod' || 'zkvote-dev' }}
          channelId: ${{ needs.prepare.outputs.environment == 'production' && 'live' || 'staging' }}
          entryPoint: ./frontend

  deploy-backend:
    needs: [prepare, deploy-contracts]
    if: |
      needs.prepare.outputs.deploy_backend == 'true' &&
      (needs.prepare.outputs.deploy_contracts == 'false' || success())
    runs-on: ubuntu-latest
    environment: ${{ needs.prepare.outputs.environment }}
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Download contract deployments
        if: needs.prepare.outputs.deploy_contracts == 'true'
        uses: actions/download-artifact@v3
        with:
          name: contract-deployment
          path: contracts/deployments/

      - name: Configure contract addresses
        if: needs.prepare.outputs.deploy_contracts == 'true'
        run: |
          mkdir -p backend/config/${{ needs.prepare.outputs.environment }}
          if [[ "${{ needs.prepare.outputs.environment }}" == "production" ]]; then
            cat contracts/deployments/mainnet/addresses.json > backend/config/production/contracts.json
          else
            cat contracts/deployments/sepolia/addresses.json > backend/config/staging/contracts.json
          fi

      - name: Login to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: ./backend
          push: true
          tags: |
            ghcr.io/${{ github.repository }}/backend:${{ needs.prepare.outputs.environment }}
            ghcr.io/${{ github.repository }}/backend:${{ github.sha }}
          build-args: |
            ENVIRONMENT=${{ needs.prepare.outputs.environment }}

      - name: Deploy to Kubernetes
        uses: digitalocean/action-doctl@v2
        with:
          token: ${{ secrets.DIGITALOCEAN_TOKEN }}
          args: kubernetes cluster kubeconfig show zkvote-${{ needs.prepare.outputs.environment }} > $GITHUB_WORKSPACE/kubeconfig.yml

      - name: Apply Kubernetes manifests
        run: |
          export KUBECONFIG=$GITHUB_WORKSPACE/kubeconfig.yml
          kubectl apply -f k8s/${{ needs.prepare.outputs.environment }}/backend-deployment.yml
          kubectl rollout restart deployment/zkvote-backend -n zkvote-${{ needs.prepare.outputs.environment }}
          kubectl rollout status deployment/zkvote-backend -n zkvote-${{ needs.prepare.outputs.environment }}

  deploy-bridge:
    needs: [prepare, deploy-contracts]
    if: |
      needs.prepare.outputs.deploy_bridge == 'true' &&
      (needs.prepare.outputs.deploy_contracts == 'false' || success())
    runs-on: ubuntu-latest
    environment: ${{ needs.prepare.outputs.environment }}
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Download contract deployments
        if: needs.prepare.outputs.deploy_contracts == 'true'
        uses: actions/download-artifact@v3
        with:
          name: contract-deployment
          path: contracts/deployments/

      - name: Configure contract addresses
        if: needs.prepare.outputs.deploy_contracts == 'true'
        run: |
          mkdir -p bridge/config/${{ needs.prepare.outputs.environment }}
          if [[ "${{ needs.prepare.outputs.environment }}" == "production" ]]; then
            cat contracts/deployments/mainnet/addresses.json > bridge/config/production/contracts.json
          else
            cat contracts/deployments/sepolia/addresses.json > bridge/config/staging/contracts.json
          fi

      - name: Login to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: ./bridge
          push: true
          tags: |
            ghcr.io/${{ github.repository }}/bridge:${{ needs.prepare.outputs.environment }}
            ghcr.io/${{ github.repository }}/bridge:${{ github.sha }}
          build-args: |
            ENVIRONMENT=${{ needs.prepare.outputs.environment }}

      - name: Deploy to Kubernetes
        uses: digitalocean/action-doctl@v2
        with:
          token: ${{ secrets.DIGITALOCEAN_TOKEN }}
          args: kubernetes cluster kubeconfig show zkvote-${{ needs.prepare.outputs.environment }} > $GITHUB_WORKSPACE/kubeconfig.yml

      - name: Apply Kubernetes manifests
        run: |
          export KUBECONFIG=$GITHUB_WORKSPACE/kubeconfig.yml
          kubectl apply -f k8s/${{ needs.prepare.outputs.environment }}/bridge-deployment.yml
          kubectl rollout restart deployment/zkvote-bridge -n zkvote-${{ needs.prepare.outputs.environment }}
          kubectl rollout status deployment/zkvote-bridge -n zkvote-${{ needs.prepare.outputs.environment }}

  post-deployment-checks:
    needs: [prepare, deploy-contracts, deploy-frontend, deploy-backend, deploy-bridge]
    if: |
      always() &&
      (needs.prepare.outputs.deploy_contracts == 'false' || needs.deploy-contracts.result == 'success') &&
      (needs.prepare.outputs.deploy_frontend == 'false' || needs.deploy-frontend.result == 'success') &&
      (needs.prepare.outputs.deploy_backend == 'false' || needs.deploy-backend.result == 'success') &&
      (needs.prepare.outputs.deploy_bridge == 'false' || needs.deploy-bridge.result == 'success')
    runs-on: ubuntu-latest
    environment: ${{ needs.prepare.outputs.environment }}
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install test dependencies
        run: npm ci
        working-directory: ./e2e

      - name: Run smoke tests
        run: npm run test:smoke -- --env=${{ needs.prepare.outputs.environment }}
        working-directory: ./e2e

      - name: Check endpoints
        run: |
          if [[ "${{ needs.prepare.outputs.environment }}" == "production" ]]; then
            BASE_URL="https://api.zkvote.io"
          else
            BASE_URL="https://api.staging.zkvote.io"
          fi

          # Check API health
          HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/health)
          if [[ $HEALTH_STATUS != 200 ]]; then
            echo "API health check failed with status $HEALTH_STATUS"
            exit 1
          fi

          # Check frontend
          if [[ "${{ needs.prepare.outputs.environment }}" == "production" ]]; then
            FRONTEND_URL="https://zkvote.io"
          else
            FRONTEND_URL="https://staging.zkvote.io"
          fi

          FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $FRONTEND_URL)
          if [[ $FRONTEND_STATUS != 200 ]]; then
            echo "Frontend check failed with status $FRONTEND_STATUS"
            exit 1
          fi

      - name: Notify successful deployment
        uses: slackapi/slack-github-action@v1.24.0
        with:
          payload: |
            {
              "text": "🚀 zkVote deployed successfully to ${{ needs.prepare.outputs.environment }}",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "🚀 *zkVote deployment successful*\n*Environment:* ${{ needs.prepare.outputs.environment }}\n*Components:* ${{ github.event.inputs.components }}"
                  }
                },
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "Deployed by ${{ github.actor }} at ${{ github.event.repository.updated_at }}"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.DEPLOYMENT_SLACK_WEBHOOK_URL }}
          SLACK_WEBHOOK_TYPE: INCOMING_WEBHOOK
```

## 11. Monitoring and Alerting

### 11.1 Status Checks Workflow

Create `.github/workflows/status-checks.yml`:

```yaml
name: Status Checks

on:
  schedule:
    - cron: "*/15 * * * *" # Every 15 minutes
  workflow_dispatch:

jobs:
  check-production:
    runs-on: ubuntu-latest
    steps:
      - name: Check API health
        id: api-health
        run: |
          HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://api.zkvote.io/health)
          if [[ $HEALTH_STATUS != 200 ]]; then
            echo "API health check failed with status $HEALTH_STATUS"
            echo "api_healthy=false" >> $GITHUB_ENV
          else
            echo "api_healthy=true" >> $GITHUB_ENV
          fi

      - name: Check frontend
        id: frontend-health
        run: |
          FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://zkvote.io)
          if [[ $FRONTEND_STATUS != 200 ]]; then
            echo "Frontend check failed with status $FRONTEND_STATUS"
            echo "frontend_healthy=false" >> $GITHUB_ENV
          else
            echo "frontend_healthy=true" >> $GITHUB_ENV
          fi

      - name: Check bridge status
        id: bridge-health
        run: |
          BRIDGE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://api.zkvote.io/bridge/health)
          if [[ $BRIDGE_STATUS != 200 ]]; then
            echo "Bridge check failed with status $BRIDGE_STATUS"
            echo "bridge_healthy=false" >> $GITHUB_ENV
          else
            echo "bridge_healthy=true" >> $GITHUB_ENV
          fi

      - name: Create GitHub issue for failed checks
        if: env.api_healthy == 'false' || env.frontend_healthy == 'false' || env.bridge_healthy == 'false'
        uses: JasonEtco/create-an-issue@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          API_HEALTHY: ${{ env.api_healthy }}
          FRONTEND_HEALTHY: ${{ env.frontend_healthy }}
          BRIDGE_HEALTHY: ${{ env.bridge_healthy }}
        with:
          filename: .github/STATUS_CHECK_TEMPLATE.md
          update_existing: true

      - name: Send alert on failure
        if: env.api_healthy == 'false' || env.frontend_healthy == 'false' || env.bridge_healthy == 'false'
        uses: slackapi/slack-github-action@v1.24.0
        with:
          payload: |
            {
              "text": "⚠️ zkVote Production Status Alert",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "⚠️ *zkVote Production Status Alert*"
                  }
                },
                {
                  "type": "section",
                  "fields": [
                    {
                      "type": "mrkdwn",
                      "text": "*API:* ${{ env.api_healthy == 'true' && '✅ Healthy' || '❌ Down' }}"
                    },
                    {
                      "type": "mrkdwn",
                      "text": "*Frontend:* ${{ env.frontend_healthy == 'true' && '✅ Healthy' || '❌ Down' }}"
                    },
                    {
                      "type": "mrkdwn",
                      "text": "*Bridge:* ${{ env.bridge_healthy == 'true' && '✅ Healthy' || '❌ Down' }}"
                    }
                  ]
                },
                {
                  "type": "actions",
                  "elements": [
                    {
                      "type": "button",
                      "text": {
                        "type": "plain_text",
                        "text": "View Status Dashboard"
                      },
                      "url": "https://status.zkvote.io"
                    }
                  ]
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.ALERT_SLACK_WEBHOOK_URL }}
          SLACK_WEBHOOK_TYPE: INCOMING_WEBHOOK
```

### 11.2 Contract Monitoring Workflow

Create `.github/workflows/contract-monitoring.yml`:

```yaml
name: Contract Monitoring

on:
  schedule:
    - cron: "*/30 * * * *" # Every 30 minutes
  workflow_dispatch:

jobs:
  monitor-contracts:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"

      - name: Install dependencies
        run: npm ci
        working-directory: ./monitoring

      - name: Run contract monitoring
        run: node scripts/monitor-contracts.js
        working-directory: ./monitoring
        env:
          INFURA_API_KEY: ${{ secrets.INFURA_API_KEY }}
          ALCHEMY_API_KEY: ${{ secrets.ALCHEMY_API_KEY }}

      - name: Check for anomalies
        run: |
          ANOMALY_DETECTED=$(cat ./monitoring/logs/anomalies.json | jq 'length')
          if [[ $ANOMALY_DETECTED -gt 0 ]]; then
            echo "ANOMALIES_FOUND=true" >> $GITHUB_ENV
            cat ./monitoring/logs/anomalies.json > anomalies.json
          else
            echo "ANOMALIES_FOUND=false" >> $GITHUB_ENV
          fi

      - name: Send alert on anomalies
        if: env.ANOMALIES_FOUND == 'true'
        uses: slackapi/slack-github-action@v1.24.0
        with:
          payload-file-path: ./monitoring/logs/slack-payload.json
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.CONTRACT_ALERT_WEBHOOK_URL }}
          SLACK_WEBHOOK_TYPE: INCOMING_WEBHOOK

      - name: Create GitHub issue for anomalies
        if: env.ANOMALIES_FOUND == 'true'
        uses: JasonEtco/create-an-issue@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          filename: .github/CONTRACT_ANOMALY_TEMPLATE.md
          update_existing: false
```

### 11.3 Performance Monitoring Workflow

Create `.github/workflows/performance-monitoring.yml`:

```yaml
name: Performance Monitoring

on:
  schedule:
    - cron: "0 */2 * * *" # Every 2 hours
  workflow_dispatch:

jobs:
  monitor-performance:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"

      - name: Install dependencies
        run: npm ci
        working-directory: ./performance

      - name: Run API performance tests
        run: node scripts/api-performance.js
        working-directory: ./performance
        env:
          API_URL: https://api.zkvote.io

      - name: Run frontend performance tests
        uses: JakePartusch/lighthouse-action@v3.1.0
        with:
          url: "https://zkvote.io"
          outputArtifacts: true

      - name: Run smart contract gas benchmarks
        run: node scripts/gas-benchmarks.js
        working-directory: ./performance
        env:
          INFURA_API_KEY: ${{ secrets.INFURA_API_KEY }}

      - name: Analyze results
        run: node scripts/analyze-performance.js
        working-directory: ./performance

      - name: Check for performance issues
        run: |
          PERF_ISSUES=$(cat ./performance/logs/performance-issues.json | jq 'length')
          if [[ $PERF_ISSUES -gt 0 ]]; then
            echo "PERFORMANCE_ISSUES=true" >> $GITHUB_ENV
          else
            echo "PERFORMANCE_ISSUES=false" >> $GITHUB_ENV
          fi

      - name: Send performance report
        if: always()
        uses: slackapi/slack-github-action@v1.24.0
        with:
          payload-file-path: ./performance/logs/performance-report.json
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.PERFORMANCE_REPORT_WEBHOOK_URL }}
          SLACK_WEBHOOK_TYPE: INCOMING_WEBHOOK

      - name: Create GitHub issue for performance problems
        if: env.PERFORMANCE_ISSUES == 'true'
        uses: JasonEtco/create-an-issue@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          filename: .github/PERFORMANCE_ISSUE_TEMPLATE.md
          update_existing: true
```

## 12. Maintenance and Troubleshooting

### 12.1 Common Pipeline Issues and Solutions

#### 12.1.1 Build Failures

| Issue                      | Possible Cause                                  | Solution                                                     |
| -------------------------- | ----------------------------------------------- | ------------------------------------------------------------ |
| **Node Module Errors**     | Dependency conflicts or outdated lockfiles      | `rm -rf node_modules && npm ci` or update lockfile           |
| **Compilation Errors**     | Typescript errors or build configuration issues | Fix type errors or update build configuration                |
| **Out of Memory Errors**   | Large builds exceeding GitHub runner limits     | Add `NODE_OPTIONS="--max-old-space-size=4096"` to build step |
| **Cache Corruption**       | Corrupted dependency cache                      | Clear cache by changing cache key or manually                |
| **ZK Circuit Compilation** | Memory intensive circom compilation             | Use specialized Docker container with increased memory       |

#### 12.1.2 Test Failures

| Issue                         | Possible Cause                            | Solution                                               |
| ----------------------------- | ----------------------------------------- | ------------------------------------------------------ |
| **Flaky Tests**               | Race conditions or timing issues          | Identify and fix flaky tests or add retries            |
| **Environment Dependencies**  | Missing environment variables or services | Ensure all required services are available in workflow |
| **Cross-Chain Test Failures** | Network issues with testnet connections   | Use local blockchain instances for testing             |
| **Gas Estimation Errors**     | Contract interaction failures             | Check contract addresses and ABI compatibility         |
| **Test Timeout**              | Long-running tests exceeding time limits  | Split tests or increase timeout limits                 |

#### 12.1.3 Deployment Failures

| Issue                     | Possible Cause                                 | Solution                                             |
| ------------------------- | ---------------------------------------------- | ---------------------------------------------------- |
| **Authentication Issues** | Expired or invalid deployment credentials      | Update secrets in GitHub repository settings         |
| **Environment Mismatch**  | Configuration doesn't match target environment | Ensure environment-specific configuration is correct |
| **Permission Issues**     | Insufficient permissions for deployment        | Check service account permissions                    |
| **Network Failures**      | Temporary connectivity issues                  | Add retry mechanisms to deployment steps             |
| **Resource Constraints**  | Kubernetes resources unavailable               | Check cluster resource allocation and quotas         |

### 12.2 Debugging Workflows

#### 12.2.1 Enabling Debug Logs

To enable debug logs in GitHub Actions:

1. Create a repository secret `ACTIONS_STEP_DEBUG` with value `true`
2. Run the workflow again to see detailed logs

#### 12.2.2 Using SSH Debugging

For complex issues, use GitHub Actions debugging via SSH:

```yaml
- name: Setup tmate session
  uses: mxschmitt/action-tmate@v3
  if: ${{ failure() }}
  with:
    limit-access-to-actor: true
```

#### 12.2.3 Workflow Dump

To inspect workflow context:

```yaml
- name: Dump GitHub context
  env:
    GITHUB_CONTEXT: ${{ toJson(github) }}
  run: echo "$GITHUB_CONTEXT"
```

### 12.3 Pipeline Maintenance

#### 12.3.1 Regular Maintenance Tasks

| Task                      | Frequency | Description                               |
| ------------------------- | --------- | ----------------------------------------- |
| **Dependency Updates**    | Weekly    | Update action versions and dependencies   |
| **Workflow Optimization** | Monthly   | Review and optimize workflows for speed   |
| **Security Review**       | Monthly   | Review workflow security and secret usage |
| **Cache Cleanup**         | Monthly   | Clear old caches to prevent bloat         |
| **Documentation Update**  | Quarterly | Ensure documentation remains current      |

#### 12.3.2 Version Bumping Strategy

For GitHub Actions versions:

```yaml
# Use exact versions for stability
- uses: actions/checkout@v3

# For less critical actions, you can use broader version specs
- uses: some-action@~1.0.0 # Compatible with 1.0.x

# Avoid using `latest` or `master` for production workflows
```

## 13. Appendices

### 13.1 Complete Repository Structure

```
zkVote/
├── .github/
│   ├── workflows/
│   │   ├── smart-contracts.yml
│   │   ├── frontend.yml
│   │   ├── backend.yml
│   │   ├── bridge.yml
│   │   ├── security.yml
│   │   ├── status-checks.yml
│   │   ├── contract-monitoring.yml
│   │   ├── performance-monitoring.yml
│   │   └── full-deployment.yml
│   ├── actions/
│   │   ├── setup-zkp-environment/
│   │   └── solidity-security-check/
│   ├── SECURITY_ISSUE_TEMPLATE.md
│   ├── STATUS_CHECK_TEMPLATE.md
│   ├── CONTRACT_ANOMALY_TEMPLATE.md
│   ├── PERFORMANCE_ISSUE_TEMPLATE.md
│   └── CODEOWNERS
├── contracts/
│   ├── src/
│   ├── test/
│   └── scripts/
├── circuits/
│   ├── vote/
│   ├── delegation/
│   └── test/
├── frontend/
│   ├── src/
│   └── public/
├── backend/
│   ├── src/
│   └── config/
├── bridge/
│   ├── src/
│   └── config/
├── sdk/
│   └── src/
├── monitoring/
│   └── scripts/
├── performance/
│   └── scripts/
├── e2e/
│   └── tests/
├── k8s/
│   ├── staging/
│   └── production/
└── docs/
    └── ci-cd/
```

### 13.2 GitHub Actions Templates

#### 13.2.1 Status Check Issue Template

Create `.github/STATUS_CHECK_TEMPLATE.md`:

```markdown
---
title: ⚠️ Status Check Failure {{ date | date('YYYY-MM-DD HH:mm') }}
labels: incident, priority-high
assignees: devops-team
---

# Status Check Failure

**Time:** {{ date | date('YYYY-MM-DD HH:mm:ss') }} UTC  
**Environment:** Production

## Service Status

| Service  | Status                                            |
| -------- | ------------------------------------------------- | --- | ------------ |
| API      | {{ env.API_HEALTHY == 'true' && '✅ Healthy'      |     | '❌ Down' }} |
| Frontend | {{ env.FRONTEND_HEALTHY == 'true' && '✅ Healthy' |     | '❌ Down' }} |
| Bridge   | {{ env.BRIDGE_HEALTHY == 'true' && '✅ Healthy'   |     | '❌ Down' }} |

## Next Steps

1. Check the [status dashboard](https://status.zkvote.io)
2. Review logs in [Datadog](https://app.datadoghq.com/dashboard/zkVote)
3. Update the incident in the [incident log](https://github.com/zkvote/ops-handbook/incidents)

Please update this issue with your findings.
```

#### 13.2.2 Security Issue Template

Create `.github/SECURITY_ISSUE_TEMPLATE.md`:

```markdown
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

## Next Steps

1. Analyze the findings in the security artifacts
2. Prioritize issues based on severity and impact
3. Create remediation tasks
4. Update this issue with an action plan

**Note:** This is an automatically generated issue. Please do not share sensitive security details in public channels.
```

### 13.3 Environment Configuration Files

#### 13.3.1 Development Environment Variables

Create `.github/development.env` (reference only, do not commit actual secrets):

```
# API Configuration
API_URL=http://localhost:3000
DATABASE_URL=postgres://postgres:postgres@localhost:5432/zkvote_dev
REDIS_URL=redis://localhost:6379

# Blockchain Configuration
INFURA_API_KEY=your_infura_key
ALCHEMY_API_KEY=your_alchemy_key
ETHERSCAN_API_KEY=your_etherscan_key

# Testing Configuration
TEST_PRIVATE_KEY=0xprivatekey
TEST_ACCOUNT_ADDRESS=0xaddress

# Feature Flags
ENABLE_CROSS_CHAIN=true
ENABLE_DELEGATION=true
```

#### 13.3.2 Docker Compose for Local Testing

Create `docker-compose.yml`:

```yaml
version: "3.8"

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: zkvote_dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:6
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  ganache:
    image: trufflesuite/ganache:latest
    ports:
      - "8545:8545"
    command:
      - --deterministic
      - --mnemonic="test test test test test test test test test test test junk"
      - --networkId=1337
      - --chain.vmErrorsOnRPCResponse=true

volumes:
  postgres_data:
  redis_data:
```

---
