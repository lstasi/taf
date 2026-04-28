# Oracle Cloud Functions

This module creates an OCI Functions application, one or more functions backed by container images, an optional API Gateway deployment, and optional monitoring alarms.

## What It Creates

- One Functions application.
- Zero or more functions from the `functions` map.
- An optional public API Gateway and deployment.
- Optional invocation and error alarms.

## Key Inputs

- `compartment_id` and `subnet_id`
- `application_display_name` and `application_config`
- `functions`: map of function definitions with image, memory, timeout, and config
- `create_api_gateway`, `api_gateway_subnet_id`, and `api_routes`
- `notification_topic_id`

## Key Outputs

- `application_id`
- `application_display_name`
- `function_ids`
- `api_gateway_id`
- `api_gateway_endpoint`
- `api_deployment_endpoint`

## Example

```hcl
module "functions" {
  source = "./oraclecloud/functions"

  compartment_id = var.compartment_id
  subnet_id      = var.private_subnet_id

  functions = {
    hello = {
      image = "iad.ocir.io/mytenancy/taf/hello-fn:latest"
    }
  }

  create_api_gateway    = true
  api_gateway_subnet_id = var.public_subnet_id
  api_routes = {
    "/hello" = {
      function_key = "hello"
      methods      = ["GET"]
    }
  }
}
```

## Important Notes

- You must build and push function images separately before applying this module.
- API Gateway is optional and uses the public endpoint type.

## Current Gaps

- No image validation or build pipeline.
- No enforcement of monthly invocation volume beyond the monitoring thresholds.
