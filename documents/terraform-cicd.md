# Terraform CI/CD pipeline

This repository uses GitHub Actions to validate changes, create an environment-specific Terraform plan, and deploy only after a protected GitHub Environment approval gate.

## Pipeline stages

### 1. Pull request and push validation
The workflow in `.github/workflows/terraform-ci.yml` runs on pull requests and on pushes to `main` or `master`.

It performs the following checks:
- `terraform fmt -check -recursive`
- `terraform init -backend=false`
- `terraform validate`

CI intentionally does not access remote state or create a plan. After CI
succeeds, the deployment workflow creates the plan using the selected GitHub
Environment and its backend configuration.

### 2. Approved deployment
The workflow in `.github/workflows/terraform-deploy.yml` handles deployment.

It is designed to:
- use GitHub OIDC with `azure/login@v2`
- require a GitHub Environment such as `dev`, `test`, or `prod`
- use environment reviewers for protected environments, especially production
- build a plan, upload it as a short-lived artifact, and require an explicit deployment approval before `terraform apply`

### 3. Drift detection
The workflow in `.github/workflows/terraform-drift.yml` runs on a weekly schedule and on manual trigger.

It performs a read-only drift check with `terraform plan -refresh-only` and does not mutate state.

## Azure authentication and trust

The pipeline uses workload identity federation instead of client secrets.

Required secrets on each deployment Environment:
- `ARM_CLIENT_ID`
- `ARM_TENANT_ID`
- `ARM_SUBSCRIPTION_ID`

Optional identity setting:
- `AZURE_CLIENT_OBJECT_ID` (recommended when Microsoft Graph lookup is restricted)

Optional backend overrides:
- `TF_BACKEND_RESOURCE_GROUP`
- `TF_BACKEND_STORAGE_ACCOUNT`
- `TF_BACKEND_CONTAINER`
- `TF_STATE_KEY`
- `TF_BACKEND_LOCATION`
- `TF_VAR_FILE` (optional for environments using a specific tfvars file)

The deployment workflow derives an Azure-standard backend name when backend
variables are not supplied. For `dev`, the defaults are
`rg-nousvia-tfstate-dev`, `stnousviatfdev<subscription-suffix>`, container
`tfstate`, and key `dev/infrastructure.tfstate`. The nine-character suffix is
derived from the subscription ID to make the storage account name globally
unique while keeping it deterministic and within Azure's 24-character limit.
The default location is `eastus`.

The plan job creates the resource group, Standard LRS StorageV2 account, and
private blob container when they do not already exist. Shared-key access and
public blob access are disabled; the workflow and Terraform backend use Entra
ID/OIDC. The workflow creates an idempotent `Storage Blob Data Contributor`
assignment for the deployment identity at the state container scope and waits
for propagation before running `terraform init`. The deployment identity must
therefore be allowed to create the resource group and storage account and must
have `Microsoft.Authorization/roleAssignments/write` at the backend scope (for
example through `Role Based Access Control Administrator`). It does not receive
broad data access outside the state container. Existing deployments can
override any default with
`TF_BACKEND_RESOURCE_GROUP`, `TF_BACKEND_STORAGE_ACCOUNT`,
`TF_BACKEND_CONTAINER`, `TF_STATE_KEY`, and `TF_BACKEND_LOCATION` on the
selected GitHub Environment. Plan and apply jobs calculate the same values
independently, and the repository does not use a local `backend.hcl`.

The Azure app registration or user-assigned managed identity must be federated to GitHub with an OIDC trust condition for this repository and branch/environment.

## Backend and state

This repository does not ship a local Azure Storage backend configuration. The
deployment workflow derives or accepts overrides for the backend configuration
and initializes it independently in each fresh runner. The downloaded plan is
checked before apply, and `terraform apply` uses that saved plan directly;
Terraform variables are already stored in the plan and are not supplied again.

For production, prefer a dedicated state account and container per environment, with locking enabled and restricted network access.

## Required repository settings

Configure the following in GitHub:
- environment secrets for the Azure identity settings above
- optional environment variables for overriding the derived backend settings
- GitHub Environment named `dev`, `test`, or `prod` as needed
- required reviewers on production
- branch protection on the default branch with required workflow checks

## Deployment safety

- No `terraform apply` is allowed without the GitHub Environment approval gate.
- The plan job may bootstrap the dedicated state resource group, storage
  account, and container when they do not exist; it does not deploy workload
  resources.
- The plan is generated before the apply step and is the exact artifact applied.
- Plan and state are treated as sensitive artifacts and are not published to PR comments.
- Drift checks are read-only and never mutate state.

## Notes

Use a real environment-specific tfvars file (for example `config/dev.tfvars`) for non-default deployments. The repo default remains safe for validation, but a real deployment should use environment-specific names and values that are valid for Azure and unique globally.
