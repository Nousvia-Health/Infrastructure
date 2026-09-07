
## Communication matrix

| Source | Destination | Protocol/port | Control |
|---|---|---|---|
| Databricks subnets | Azure Databricks control plane | TCP 443, 3306, 8443-8451 | Databricks-generated NSG rules |
| Databricks subnets | ADLS Gen2 private endpoints | TCP 443 | Private endpoints and private DNS |
| Databricks subnets | Event Hubs | TCP 9093 | Databricks-generated NSG rule |
| VNet workloads | Private DNS zones | DNS TCP/UDP 53 | VNet-linked private DNS zones |
| Terraform identity | Azure Resource Manager | HTTPS 443 | Entra authentication and RBAC |

## Operational decisions and gaps

- The four customer resource groups are separate lifecycle boundaries. `NetworkWatcherRG` is retained as the Azure-managed watcher boundary.
- No RTO/RPO, backup policy, cross-region design, owner, or cost-center requirement was supplied. The current Trial Databricks and LRS storage posture is development-only.
- Monitoring is represented by the existing Log Analytics workspace. Optional diagnostic settings accept explicit target resource IDs, but remain empty until the live category and destination requirements are supplied; arbitrary alerts are intentionally not created.
- Public network access remains part of the imported live state. A future hardening change should first verify private DNS, identity paths, Databricks control-plane requirements, and application dependencies, then use an approved plan.

## Terraform layout

The root composes modules for resource groups, network, storage, private endpoints, monitoring, Key Vault, access connector, Databricks, and Network Watcher. `imports.tf` contains resource IDs for adoption. No Terraform resource is declared for Databricks-managed resource-group children, generated private endpoint NICs, or network intent policies.
# Live Dev Adoption

## Scope

This Terraform root is an adoption model for subscription `97ee3b56-2c25-44f9-a1bc-d603a09efc45` in `eastus2`. It declares the existing dev resource groups, shared VNet, subnets that are safe to own, storage account, access connector, Key Vault, Log Analytics workspace, Databricks workspace, private endpoints, private DNS zones, DNS links, NAT gateway, public IP, NSG, and Network Watcher.

The `config/dev.tfvars` file is local configuration and is ignored by Git. The tracked example contains resource IDs but no keys, secret values, workspace URL, or child metadata.

## Adoption procedure

1. Authenticate to tenant `9629acab-3a56-4de8-85c5-bd2af6dd3bd0` and select the supplied subscription.
2. Run `terraform init -backend=false`, `terraform fmt -check -recursive`, and `terraform validate`.
3. Review the import blocks in `imports.tf` and use `terraform plan -var-file=config/dev.tfvars` only after remote state and approval are configured.
4. Import resources using the reviewed import blocks or an equivalent controlled import workflow. Do not run import or apply from this repository without approval.
5. Run a plan after adoption and investigate every replacement, tag change, network rule change, RBAC change, and public-network change.

## Deliberate exclusions

Databricks owns the managed resource group `mrg-dbw-nousviahealth-dev-eus2` and its storage account `dbstoragesxumyprgbz4fu`, access connector `unity-catalog-access-connector`, user-assigned identity `dbmanagedidentity`, and Event Grid system topic. These are documented dependencies, not independently managed Terraform resources.

Databricks-generated NSG `databricksnsgwtzfq4y2p7vjy`, its rules, delegated workspace subnet ranges, private endpoint NICs, and network intent policies are platform-generated or workspace-owned. The workspace module reads the delegated subnet/NSG association; it does not create or mutate those children.

The network module does not attach the NAT Gateway to a subnet because no intended live association was evidenced. Set `nat_gateway_subnet_name` only after the target subnet and ownership are approved. The imported NSG is marked `platform_managed`; no rules or Databricks subnet associations are declared by Terraform.

`NetworkWatcherRG` is an Azure-managed resource group. Its tags are explicit adoption inputs, but Azure-managed ownership remains the boundary for Network Watcher lifecycle decisions. All adopted resource groups use Terraform's `prevent_destroy` safeguard; import is still supported, while any deliberate deletion requires an explicit reviewed code change to remove that safeguard.

Key Vault secrets and storage child metadata/shares were not retrieved. No secret values are represented in Terraform. The current identity was forbidden from listing Key Vault secret metadata, so secret inventory remains an operational follow-up.

## Live cost and security posture

The live storage account is Standard LRS and the Databricks workspace is Trial. Trial and LRS are development-only choices. Public network access remains explicitly enabled on the live storage account, Key Vault, Log Analytics ingestion/query surfaces, and Databricks workspace; changing that posture is a separate approved security change because it can affect clients and control-plane operations. Production acceptance requires private DNS validation, approved private/control-plane paths, and a reviewed no-public-access plan for each service.

The live Key Vault uses RBAC, 90-day soft delete, and no purge protection. `purge_protection_enabled` is explicit and remains false for supplied dev adoption. Production must opt in after confirming the irreversible purge-protection behavior and retention/legal requirements. The private endpoints and private DNS links provide private data-plane paths but do not by themselves disable public access.

Storage keeps shared-key access enabled in dev and uses LRS. Production requires an approved Entra/RBAC data-access design, shared-key disablement where supported by all clients, public access restrictions, and ZRS/GZRS selection against documented RTO/RPO. Diagnostic destinations, categories, retention, alert action groups, Defender, Policy, and backup remain operational acceptance items until their live IDs and requirements are supplied.
