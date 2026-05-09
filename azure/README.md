# Azure Always Free Modules

This directory contains the implemented Azure modules in TAF. The focus is on Azure services with ongoing free allowances or low-cost entry points that can realistically stay inside a perpetual free operating envelope.

## Implemented Modules

| Module | Status | Purpose | Main Caveat |
| --- | --- | --- | --- |
| [billing-alerts](billing-alerts/README.md) | Implemented | Subscription budget, action group, optional anomaly alert | Budgets notify but do not hard-stop spend |
| [functions](functions/README.md) | Implemented | Function App platform on Consumption plan | Module creates the platform, not the function code artifact |
| [cosmos-db](cosmos-db/README.md) | Implemented | Free-tier Cosmos DB account, SQL database, containers | Azure allows only one free-tier account per subscription |
| [event-grid](event-grid/README.md) | Implemented | Custom topic, subscriptions, optional alerting | Monthly operations are not enforced in code |
| [service-bus](service-bus/README.md) | Implemented | Basic namespace, queues, optional auth rules and alerts | Queue usage is still workload-dependent |
| [notification-hubs](notification-hubs/README.md) | Implemented | Free namespace and hub with optional platform credentials | Push volume is not enforced in code |

## Recommended Order

1. Start with [billing-alerts](billing-alerts/README.md).
2. Add one service module at a time.
3. Keep subscription-wide free-tier limits in mind, especially for Cosmos DB.

## Shared Caveats

- Azure usage limits are often subscription-wide or workload-driven, so several modules can only document the limit rather than enforce it.
- Most Azure modules in this repo create their own resource group as part of the deployment surface.
- The Azure Functions module provisions the hosting platform only. You still need a deployment flow for function code.

## Missing Work

- Working examples for the Azure modules.
- CI validation and security scanning.
- Stronger guardrails around subscription-wide free-tier usage.
