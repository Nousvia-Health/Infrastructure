# Terraform Configuration

Environment configuration files are Terraform variable files. Keep one file per deployment environment. The root composition is keyed by logical names: `resource_groups`, `networks`, `storage_accounts`, and `private_endpoints`.

## Create a local configuration

```powershell
Copy-Item config/dev.tfvars.example config/dev.tfvars
```

Replace every `replace-me` and `replacewith...` value. Storage account names must be globally unique, lowercase, and 3-24 characters. Each resource explicitly selects its owning resource group; multiple storage accounts and shares can be added under `storage_accounts` without duplicating root module wiring. Network, storage account, and private endpoint entries can optionally set `location` and `tags`; omitted values inherit the deployment resource group location and global tags. Every private endpoint subnet CIDR must be inside its VNet and must not overlap another configured network or subnet. Networks sharing a resource group must also use distinct `private_dns_zone_name` values; the same zone name is allowed in different resource groups.

Real `*.tfvars` files are ignored by Git because they may contain environment-specific or sensitive values. The example files are safe templates and are tracked.

## Local commands

```powershell
terraform fmt -check
terraform init -backend=false
terraform validate
terraform plan -var-file=config/dev.tfvars -out=tfplan
```

Use the same pattern for production:

```powershell
terraform plan -var-file=config/prod.tfvars -out=tfplan
```

CI/CD should set `TF_VAR_FILE` from the deployment environment and pass it to every Terraform command. State must have a separate backend key and approval boundary per environment; this repository does not configure or apply a backend.

Review the plan before applying. Apply only an approved plan:

```powershell
terraform apply tfplan
```

## CI/CD usage

The pipeline should select the configuration through an environment variable:

```yaml
env:
  TF_VAR_FILE: config/dev.tfvars
```

Use the selected file in every Terraform command:

```text
terraform plan -var-file="$TF_VAR_FILE" -out=tfplan
terraform apply tfplan
```

For GitHub Actions, store non-secret values in repository or environment variables and sensitive values in GitHub encrypted secrets or Azure Key Vault. Do not commit real `.tfvars` files, state, plans, credentials, or storage keys. Production must use a protected GitHub Environment with required reviewers.

## Adding resources

1. Add a resource group key when the resource has a distinct lifecycle or ownership boundary.
2. Add a network key for reusable VNet, subnet, NSG, and shared Files private DNS resources.
3. Add a storage account key and one or more `file_shares` entries.
4. Add a private endpoint entry referencing the resource group, network, and storage account keys.
5. Review the environment's subscription, backend, approval owners, CIDRs, and resource scope before deployment.

The legacy singular variables remain available for the original one-share deployment. When used, they are translated to the `deployment` resource group, `deployment` network, `storage` account, and `shared` share keys. Do not mix `resource_groups` with only some of the other keyed maps: map mode requires all four maps, and the root validates every cross-reference before dependent resources are created.

For multiple shares, use the keyed `file_share_urls` output. The singular `file_share_url` compatibility output uses the first share by sorted logical key, so it is deterministic but should not be used when a caller needs every share.
