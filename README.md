# Terraform Always Free (TAF)

Terraform Always Free (TAF) is a collection of Terraform modules for cloud resources that have a perpetual free allowance. The repository is no longer in a documentation-only phase: AWS, Azure, Oracle Cloud Infrastructure, and Cloudflare modules are implemented and documented.

## Current Status

| Provider | Status | Implemented Modules | Notes |
| --- | --- | --- | --- |
| AWS | Implemented | 7 | Billing alerts, Lambda, DynamoDB, CloudWatch, SNS, SQS, Step Functions |
| Azure | Implemented | 6 | Billing alerts, Functions, Cosmos DB, Event Grid, Service Bus, Notification Hubs |
| Oracle Cloud Infrastructure | Implemented | 6 | Billing alerts, Networking, Compute, Autonomous DB, Object Storage, Functions |
| Cloudflare | Implemented | 1 | Pages (project, GitHub source integration, custom domain) |
| GCP | Not started | 0 | No provider directory in the repo yet |
| DigitalOcean | Not started | 0 | No provider directory in the repo yet |

Implemented Terraform modules: 20

## What Exists Today

- Reusable Terraform modules under [aws/README.md](aws/README.md), [azure/README.md](azure/README.md), [oraclecloud/README.md](oraclecloud/README.md), and [cloudflare/README.md](cloudflare/README.md).
- Module-level READMEs for every implemented module.
- One working example for AWS billing alerts in [aws/billing-alerts/examples/basic/README.md](aws/billing-alerts/examples/basic/README.md).
- Provider and module version constraints in each module's `versions.tf`.

## What Is Still Missing

- Working examples for most implemented modules.
- CI validation and formatting checks.
- Automated security scanning and cost guardrails.
- Stronger validation for provider-wide aggregate free-tier quotas.
- Any Terraform module code for GCP and DigitalOcean.

## Repository Layout

```text
taf/
├── README.md
├── ARCHITECTURE.md
├── TODO.md
├── aws/
│   ├── billing-alerts/
│   ├── cloudwatch/
│   ├── dynamodb/
│   ├── lambda/
│   ├── sns/
│   ├── sqs/
│   └── step-functions/
├── azure/
│   ├── billing-alerts/
│   ├── cosmos-db/
│   ├── event-grid/
│   ├── functions/
│   ├── notification-hubs/
│   └── service-bus/
├── cloudflare/
│   └── pages/
└── oraclecloud/
    ├── autonomous-db/
    ├── billing-alerts/
    ├── compute/
    ├── functions/
    ├── networking/
    └── object-storage/
```

## Getting Started

1. Choose a provider that already has module code.
2. Read that provider README before selecting modules.
3. Deploy the provider's billing-alerts module first when one exists.
4. Start from a module README and run `terraform init`, `terraform validate`, and `terraform plan` in a sandbox account or tenancy.

## Review Summary

The codebase is materially ahead of the original documentation. The main review outcome is not that modules are missing, but that the documentation had drifted and several always-free limits are documented rather than fully enforced in Terraform.

Important caveats discovered during review:

- AWS Lambda requires either a local ZIP file or an S3 object for the deployment package; the module does not currently validate that one is supplied before apply.
- AWS DynamoDB validates per-table capacity, but the always-free 25 RCU and 25 WCU allowances are account-wide totals, not per-table totals.
- AWS CloudWatch can create more alarms and log resources than the always-free allowance if you configure large maps.
- AWS SNS email subscriptions require manual confirmation before notifications are active.
- Azure Cosmos DB free tier is limited to one free-tier account per subscription; the module enables free tier but cannot reserve that slot.
- OCI compute and storage modules validate per-resource shape limits, but tenancy-wide always-free capacity still has to be managed across deployments.

## Documentation Map

- [ARCHITECTURE.md](ARCHITECTURE.md): how the repository is organized and how the modules are intended to fit together.
- [TODO.md](TODO.md): implemented work, open gaps, and review-driven backlog items.
- Provider READMEs: implementation status and provider-specific caveats.
- Module READMEs: resources created, key inputs and outputs, example usage, and current limitations.

## Usage Guidance

- Treat the modules as building blocks, not a full platform.
- Stay inside the documented free-tier limits for each provider.
- Validate plans in a low-risk account before applying in anything long-lived.
- Re-check provider pricing pages periodically; always-free programs change over time.

## License

MIT. See [LICENSE](LICENSE).
