# Infrastructure

Terraform infrastructure for Azure resources.

## Configuration

Environment-specific Terraform variables are kept under [config](config/). Start with [config/dev.tfvars.example](config/dev.tfvars.example) or [config/prod.tfvars.example](config/prod.tfvars.example), copy it to a local `.tfvars` file, and replace the placeholder values.

The root is a composition boundary: keyed `resource_groups`, `networks`, `storage_accounts`, and `private_endpoints` maps allow resources to use different resource groups and shared networking. A network owns the reusable Azure Files private DNS zone, and each storage account can contain keyed `file_shares`. Network, storage account, and private endpoint entries may override their resource group location and tags. The original singular variables remain a compatibility form for the current one-share deployment, and the repo includes a safe default storage account name so basic validation can run without environment-specific tfvars; real deployments should override these values in `config/*.tfvars` to ensure globally unique names and environment-specific settings.

Each private endpoint subnet must be fully contained in its network address space. Network address spaces and private endpoint subnet CIDRs must not overlap across network entries. A private DNS zone name may be used by only one network in a given resource group; the root rejects duplicate resource-group/zone-name pairs because Azure DNS zone names are resource-group scoped. Keyed outputs are authoritative for map mode. The singular share URL compatibility output selects the first share by sorted logical key and does not assume a `shared` key.

Use the same variable file for local Terraform commands and CI/CD by passing `-var-file`:

```powershell
terraform plan -var-file=config/dev.tfvars -out=tfplan
terraform apply tfplan
```

See [config/README.md](config/README.md) for environment configuration, GitHub Actions usage, protected production deployment, and secret-handling guidance.

Terraform state is environment-specific and must use a separately configured remote backend with locking in shared environments. This repository intentionally does not configure a backend or run deployment operations.
