# Terraform Always Free (TAF) Architecture

## Overview

TAF is organized as a set of provider-specific Terraform modules that aim to stay within perpetual free allowances. The repository now has real module implementations for AWS, Azure, and Oracle Cloud Infrastructure, plus documentation-only coverage for Cloudflare.

The design goal is simple: keep each module small, provider-native, and explicit about the free-tier assumptions it relies on.

## Core Principles

1. Always-free resources only. Temporary trials and 12-month introductory offers are out of scope.
2. Billing protection first. Providers with billing alert primitives get a dedicated `billing-alerts` module.
3. Small modules. Each module owns one service area and exposes only the inputs needed for that service.
4. Free-tier caveats are documented. Where Terraform cannot enforce a provider-wide quota, the README must call it out.
5. Prefer safe defaults. Implementations should default toward free SKUs, free shapes, or conservative monitoring thresholds.

## Repository Structure

```text
taf/
├── README.md
├── ARCHITECTURE.md
├── TODO.md
├── aws/
│   ├── README.md
│   ├── billing-alerts/
│   ├── cloudwatch/
│   ├── cognito/
│   ├── dynamodb/
│   ├── lambda/
│   ├── sns/
│   ├── sqs/
│   └── step-functions/
├── azure/
│   ├── README.md
│   ├── billing-alerts/
│   ├── cosmos-db/
│   ├── event-grid/
│   ├── functions/
│   ├── notification-hubs/
│   └── service-bus/
├── cloudflare/
│   └── README.md
└── oraclecloud/
    ├── README.md
    ├── autonomous-db/
    ├── billing-alerts/
    ├── compute/
    ├── functions/
    ├── networking/
    └── object-storage/
```

## Module Layout

Implemented modules follow a consistent Terraform layout:

```text
module-name/
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
└── versions.tf
```

Expected responsibilities per file:

- `main.tf`: resource definitions and locals.
- `variables.tf`: public interface, defaults, and validations.
- `outputs.tf`: values needed by downstream modules or consumers.
- `versions.tf`: Terraform and provider version constraints.
- `README.md`: created resources, free-tier assumptions, usage, outputs, and known gaps.

## Provider Coverage

### AWS

Implemented modules:

- `billing-alerts`
- `lambda`
- `dynamodb`
- `cloudwatch`
- `sns`
- `sqs`
- `step-functions`
- `cognito`

Design notes:

- Modules generally prefer direct AWS resources over wrapper abstractions.
- Billing protection uses CloudWatch billing alarms, SNS notifications, and optional AWS Budgets.
- Some AWS always-free limits are account-wide, so module validation can only go so far inside a single module boundary.

### Azure

Implemented modules:

- `billing-alerts`
- `functions`
- `cosmos-db`
- `event-grid`
- `service-bus`
- `notification-hubs`

Design notes:

- Modules pin to free or low-cost SKUs where that is the main free-tier entry point.
- Azure modules usually create their own resource group as part of the deployment surface.
- Subscription-wide constraints such as the single free-tier Cosmos DB account have to be documented rather than strictly enforced.

### Oracle Cloud Infrastructure

Implemented modules:

- `billing-alerts`
- `networking`
- `compute`
- `autonomous-db`
- `object-storage`
- `functions`

Design notes:

- OCI modules are the strongest example of hard free-tier guardrails in this repo.
- Compute shapes and Autonomous Database free-tier settings are constrained directly in code.
- Some OCI allowances remain tenancy-wide totals, especially A1 compute capacity and block storage.

### Cloudflare

Current state:

- Provider overview only.
- No Terraform modules are implemented in this repository yet.

## Architectural Constraints

Not every free-tier promise can be encoded in Terraform validation. The main constraint categories are:

- Account-wide quotas. Example: AWS DynamoDB free throughput is shared across all tables in the account.
- Subscription-wide quotas. Example: Azure Cosmos DB allows only one free-tier account per subscription.
- Tenancy-wide quotas. Example: OCI A1 Flex OCPU and block storage allowances are shared totals.
- Usage-based limits. Example: requests, executions, or event volume can only be estimated ahead of time.

Because of that, the repository follows a mixed strategy:

- Enforce what can be enforced in variables and resource defaults.
- Document what cannot be enforced reliably.
- Encourage billing-alert modules and conservative thresholds.

## Documentation Contract

Every provider or module README should answer these questions:

1. What resources does this module create?
2. Which free-tier assumptions does it rely on?
3. Which inputs matter most?
4. Which outputs are intended for composition?
5. What is implemented already and what is still missing?
6. What caveats can lead to charges even if the module itself plans successfully?

## Validation Strategy

Current state:

- Manual `terraform init`, `terraform validate`, and `terraform plan` per module.
- No repository-wide CI workflow yet.
- No automated security or policy scanning checked into the repo yet.

Planned improvements:

- Recursive formatting and validation in CI.
- Example-based validation for implemented modules.
- Security scanning with tools such as `tfsec` or `checkov`.
- Additional validation for known free-tier edge cases.

## Expansion Areas

The next architectural additions should focus on depth before breadth:

1. Add working examples for existing modules.
2. Add CI and security checks.
3. Tighten free-tier guardrails where validation is practical.
4. Only then expand into Cloudflare modules and new providers such as GCP or DigitalOcean.
