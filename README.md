# Infrastructure

Terraform infrastructure for Azure resources.

This repository currently models adoption of the live NousviaHealth dev environment described in [documents/adoption.md](documents/adoption.md). The older generic Azure Files composition described below is stale and is retained only as historical context; use the live dev inputs and import manifest for this environment.

## Configuration

Environment-specific Terraform variables are kept under [config](config/). Start with [config/dev.tfvars.example](config/dev.tfvars.example) or [config/prod.tfvars.example](config/prod.tfvars.example), copy it to a local `.tfvars` file, and replace the placeholder values.

The active root composes existing resource groups, a shared VNet, ADLS Gen2 storage, private endpoints and DNS, Log Analytics, Key Vault, Databricks, an access connector, and Network Watcher. `imports.tf` is for controlled adoption only; do not import or apply without approval.

Tagging is configured through the root `common_tags` map in the selected tfvars file. The shared tags are applied to all supported Terraform resources, while resource-specific tags override shared values. The dev configuration records the required environment, workload, organization, management, data-classification, and cost-center metadata. Azure subnets and diagnostic-setting resources do not expose tags; Databricks-generated resources and platform-managed NSG rules remain outside Terraform tag ownership.

Set the optional `databricks` object to adopt the existing private `nousviahealth-dev` workspace. The module reads the Databricks-managed workspace subnet associations and does not declare generated resource-group children, NSG rules, private endpoint NICs, or network intent policies. Public network access and secure connectivity are explicit environment inputs; the supplied dev configuration preserves the observed live posture.

Each private endpoint subnet must be fully contained in its network address space. Network address spaces and private endpoint subnet CIDRs must not overlap across network entries. A private DNS zone name may be used by only one network in a given resource group; the root rejects duplicate resource-group/zone-name pairs because Azure DNS zone names are resource-group scoped. Keyed outputs are authoritative for map mode. The singular share URL compatibility output selects the first share by sorted logical key and does not assume a `shared` key.

Use the same variable file for local Terraform commands and CI/CD by passing `-var-file`:

```powershell
terraform plan -var-file=config/dev.tfvars -out=tfplan
terraform apply tfplan
```

See [config/README.md](config/README.md) for environment configuration, GitHub Actions usage, protected production deployment, and secret-handling guidance.

Terraform state is environment-specific and must use a separately configured remote backend with locking in shared environments. This repository intentionally does not configure a backend or run deployment operations.
