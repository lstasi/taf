# Azure Functions

This module provisions the Azure Functions hosting platform on the Consumption plan. It does not package or publish function code.

## What It Creates

- A resource group.
- A storage account required by Azure Functions.
- A `Y1` Consumption plan service plan.
- A Linux or Windows Function App.
- An optional execution-count alert.

## Key Inputs

- `resource_group_name` and `location`.
- `function_app_name` and `storage_account_name`.
- `os_type`, `runtime`, and `runtime_version`.
- `app_settings`.
- `enable_monitoring` and `action_group_id`.

## Key Outputs

- `function_app_id`
- `function_app_name`
- `function_app_default_hostname`
- `storage_account_name`
- `identity_principal_id`

## Example

```hcl
module "functions" {
  source = "./azure/functions"

  resource_group_name = "rg-taf-functions"
  location            = "eastus"
  function_app_name   = "taf-func-app"
  storage_account_name = "taffuncsa01"
  runtime             = "node"
  runtime_version     = "18"

  app_settings = {
    FUNCTIONS_EXTENSION_VERSION = "~4"
  }
}
```

## Important Notes

- This module creates the hosting platform only. Deploy function code separately with Zip Deploy, CI, or another release flow.
- Free usage is based on executions and GB-seconds, which this module cannot predict.

## Current Gaps

- No application artifact build or publish flow.
- No enforcement of monthly execution or GB-second usage.
