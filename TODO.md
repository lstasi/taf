# Terraform Always Free (TAF) TODO

## Current State

- Top-level documentation has been aligned with the codebase.
- AWS provider modules are implemented.
- Azure provider modules are implemented.
- Oracle Cloud Infrastructure modules are implemented.
- Cloudflare has provider-level documentation only.
- GCP and DigitalOcean are not started in this repository.

## Implemented Modules

### AWS

- [x] billing-alerts
- [x] lambda
- [x] dynamodb
- [x] cloudwatch
- [x] sns
- [x] sqs
- [x] step-functions

### Azure

- [x] billing-alerts
- [x] functions
- [x] cosmos-db
- [x] event-grid
- [x] service-bus
- [x] notification-hubs

### Oracle Cloud Infrastructure

- [x] billing-alerts
- [x] networking
- [x] compute
- [x] autonomous-db
- [x] object-storage
- [x] functions

### Documentation-Only Areas

- [x] Cloudflare provider overview
- [ ] Cloudflare Terraform modules
- [ ] GCP provider overview and modules
- [ ] DigitalOcean provider overview and modules

## Review-Driven Backlog

### High Priority

- [ ] Add examples for every implemented module.
- [ ] Add CI for `terraform fmt -check` and `terraform validate`.
- [ ] Add security scanning with `tfsec`, `checkov`, or equivalent.
- [ ] Add a provider-by-provider comparison matrix at the root.

### Free-Tier Guardrail Improvements

- [ ] AWS Lambda: validate that either `filename` or `s3_bucket` and `s3_key` are supplied.
- [ ] AWS DynamoDB: document and, where practical, guard against aggregate account-wide RCU and WCU limits.
- [ ] AWS DynamoDB: warn about GSI capacity contributing to the same free-tier allowance.
- [ ] AWS CloudWatch: add validation or explicit warnings for alarm and metric counts that exceed the always-free allowance.
- [ ] AWS Step Functions: validate the state machine definition format earlier when practical.
- [ ] Azure Functions: add stronger storage account naming validation.
- [ ] Azure Cosmos DB: call out and possibly detect the one-free-tier-account-per-subscription constraint.
- [ ] OCI Compute: document tenancy-wide A1 Flex and block volume sharing more prominently.
- [ ] OCI Object Storage: add stronger bucket naming validation.

### Documentation and Examples

- [ ] Add copy-paste examples that compose billing alerts with one service module per provider.
- [ ] Add troubleshooting guidance for provider authentication and region selection.
- [ ] Add example test instructions for AWS billing alerts after SNS subscription confirmation.
- [ ] Add a root-level provider selection guide.

### Validation and Operations

- [ ] Add a simple makefile or task runner for formatting and validation.
- [ ] Add pre-commit hooks.
- [ ] Add example validation in CI.
- [ ] Add release/versioning guidance for publishing modules.

## Near-Term Recommended Order

1. Examples for existing modules.
2. CI validation and formatting.
3. Security scanning.
4. Guardrail improvements for the known free-tier gaps.
5. Cloudflare module implementation.
6. New provider expansion.

## Notes

- Billing-alert modules should remain the first deployment recommendation for any provider that supports them.
- Free-tier documentation needs periodic review because cloud provider quotas and pricing change.
- A Terraform plan succeeding does not guarantee the resulting deployment stays within account-wide, subscription-wide, or tenancy-wide free limits.
