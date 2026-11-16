#!/bin/bash
set -euo pipefail

# Wrapper script for gcloud auth application-default login using the Terraform service account.
#
# After running this script, you can run commands such as terraform init locally.
#
# Prerequisites:
# - The gcloud command is installed.
# - terraform.tfvars exists in the parent directory of this script.
# - The user running this script has roles/iam.serviceAccountTokenCreator on the Terraform service account.
#   - e.g. gcloud iam service-accounts add-iam-policy-binding terraform@PROJECT_ID.iam.gserviceaccount.com --project=PROJECT_ID --role=roles/iam.serviceAccountTokenCreator --member="user:YOUR_EMAIL"

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PARENT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly TFVARS_FILE="${PARENT_DIR}/terraform.tfvars"

PROJECT_ID=$(grep -E '^[[:space:]]*gcp_project_id[[:space:]]*=' "${TFVARS_FILE}" | head -n 1 | sed -E 's/^[[:space:]]*gcp_project_id[[:space:]]*=[[:space:]]*"([^"]*)".*/\1/' || true)
readonly PROJECT_ID

if [ -z "${PROJECT_ID}" ]; then
  echo "ERROR: Failed to read gcp_project_id from ${TFVARS_FILE}." >&2
  exit 1
fi

readonly SA_NAME="${SA_NAME:-terraform}"

readonly SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "INFO: Authenticating as ${SA_EMAIL}."

gcloud auth application-default login --impersonate-service-account="${SA_EMAIL}"
