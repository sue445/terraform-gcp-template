#!/bin/bash
set -euo pipefail

BACKEND_BUCKET_NAME=""
BUCKET_LOCATION="us"
PROJECT_ID=""
DRY_RUN=false
GITHUB_USERNAME=""
GITHUB_REPOSITORY=""

usage() {
  echo "Usage: $0 --project <gcp-project-id> --github-username <github-username> --github-repository <github-repository> [--backend <bucket-name>] [--location <gcs-location>] [--dry-run]"
  echo "Example: $0 --project your-gcp-project-id --github-username octocat --github-repository your-gcp-project-terraform --backend your-gcp-project-terraform --location asia-northeast1 --dry-run"
  exit 1
}

run() {
  local max_attempts=3
  local delay=2
  local attempt=1

  if $DRY_RUN; then
    echo "[DRY_RUN] $*"
    return 0
  fi

  until "$@"; do
    if (( attempt >= max_attempts )); then
      echo " Command failed after $attempt attempts: $*" >&2
      return 1
    fi
    echo " Command failed (attempt $attempt), retrying in $delay seconds..." >&2
    sleep $delay
    ((attempt++))
  done
}

# parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT_ID="$2"
      shift 2
      ;;
    --backend)
      BACKEND_BUCKET_NAME="$2"
      shift 2
      ;;
    --location)
      BUCKET_LOCATION="$2"
      shift 2
      ;;
    --github-username)
      GITHUB_USERNAME="$2"
      shift 2
      ;;
    --github-repository)
      GITHUB_REPOSITORY="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

if [[ -z "$PROJECT_ID" ]]; then
  echo "[ERROR] --project <gcp-project-id> is required"
  usage
fi

if [[ -z "$GITHUB_USERNAME" ]]; then
  echo "[ERROR] --github-username <github-username> is required"
  usage
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "[ERROR] --github-repository <github-repository> is required"
  usage
fi

if [[ -z "$BACKEND_BUCKET_NAME" ]]; then
  BACKEND_BUCKET_NAME="${PROJECT_ID}-terraform"
fi

readonly SERVICE_ACCOUNT_NAME="terraform"
readonly SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
readonly PROVIDER_ID="github-actions"
readonly POOL_ID="github-actions"

# Enable APIs
run gcloud services enable --project="$PROJECT_ID" \
  iamcredentials.googleapis.com \
  iam.googleapis.com \
  storage.googleapis.com \
  cloudresourcemanager.googleapis.com

# Create Service Account
if ! gcloud iam service-accounts describe "$SERVICE_ACCOUNT_EMAIL" --project="$PROJECT_ID" &>/dev/null; then
  run gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" --display-name="$SERVICE_ACCOUNT_NAME" --project="$PROJECT_ID"

  if ! $DRY_RUN; then
    echo "[INFO] Created service account: $SERVICE_ACCOUNT_EMAIL"
  fi
else
  echo "[INFO] Service account already exists: $SERVICE_ACCOUNT_EMAIL"
fi

# Grant role to Service Account
for ROLE in \
  roles/storage.admin \
  roles/iam.workloadIdentityPoolAdmin \
  roles/iam.serviceAccountAdmin; do

  if gcloud projects get-iam-policy "$PROJECT_ID" \
    --flatten="bindings[].members" \
    --filter="bindings.role=${ROLE} AND bindings.members=serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --format="value(bindings.members)" | grep -q .; then

    echo "[INFO] Role $ROLE already granted to $SERVICE_ACCOUNT_EMAIL"
  else
    run gcloud projects add-iam-policy-binding "$PROJECT_ID" \
      --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
      --role="$ROLE"
    if ! $DRY_RUN; then
      echo "[INFO] Granted role $ROLE to $SERVICE_ACCOUNT_EMAIL"
    fi
  fi
done

# Create GCS bucket for backend
if ! gsutil ls -b "gs://${BACKEND_BUCKET_NAME}" &>/dev/null; then
  run gcloud storage buckets create "gs://$BACKEND_BUCKET_NAME"  --project="$PROJECT_ID" --location="$BUCKET_LOCATION"

  if ! $DRY_RUN; then
    echo "[INFO] Created bucket: gs://${BACKEND_BUCKET_NAME} in $BUCKET_LOCATION"
  fi

  run gcloud storage buckets update "gs://$BACKEND_BUCKET_NAME" --project="$PROJECT_ID" --versioning

  if ! $DRY_RUN; then
    echo "[INFO] Enabled versioning on bucket: gs://${BACKEND_BUCKET_NAME}"
  fi
else
  echo "[INFO] Bucket already exists: gs://${BACKEND_BUCKET_NAME} in $BUCKET_LOCATION"
fi

# Create Workload Identity Pool
if ! gcloud iam workload-identity-pools describe "$POOL_ID" --project="$PROJECT_ID" --location="global" &>/dev/null; then
  run gcloud iam workload-identity-pools create "$POOL_ID" --project="$PROJECT_ID" --location="global"

  if ! $DRY_RUN; then
    echo "[INFO] Created Workload Identity Pool: $POOL_ID"
  fi
else
  echo "[INFO] Workload Identity Pool already exists: $POOL_ID"
fi

# Create Workload Identity Pool Provider
if ! gcloud iam workload-identity-pools providers describe "$PROVIDER_ID" \
  --project="$PROJECT_ID" \
  --workload-identity-pool="$POOL_ID" \
  --location="global" &>/dev/null; then

  run gcloud iam workload-identity-pools providers create-oidc "$PROVIDER_ID" \
    --project="$PROJECT_ID" \
    --location="global" \
    --workload-identity-pool="$POOL_ID" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
    --attribute-condition="assertion.repository_owner=='${GITHUB_USERNAME}'"

  if ! $DRY_RUN; then
    echo "[INFO] Created OIDC Provider: $PROVIDER_ID"
    echo "[INFO] Waiting for Workload Identity Pool to be fully ready..."
    sleep 10
  fi
else
  echo "[INFO] OIDC Provider already exists: $PROVIDER_ID"
fi

POOL_RESOURCE=""
if ! $DRY_RUN; then
  POOL_RESOURCE=$(gcloud iam workload-identity-pools describe "$POOL_ID" --project="$PROJECT_ID" --location="global" --format="value(name)")
fi

# Add Workload Identity User role to Service Account
readonly MEMBER="principalSet://iam.googleapis.com/${POOL_RESOURCE}/attribute.repository/${GITHUB_USERNAME}/${GITHUB_REPOSITORY}"

if ! gcloud iam service-accounts get-iam-policy "$SERVICE_ACCOUNT_EMAIL" \
  --format="flattened(bindings[].members)" \
  --project="$PROJECT_ID" | grep -q "${MEMBER}"; then

  run gcloud iam service-accounts add-iam-policy-binding "$SERVICE_ACCOUNT_EMAIL" \
    --project="$PROJECT_ID" \
    --role="roles/iam.workloadIdentityUser" \
    --member="$MEMBER"

  if ! $DRY_RUN; then
    echo "[INFO] Bound $MEMBER to $SERVICE_ACCOUNT_EMAIL as roles/iam.workloadIdentityUser"
  fi
else
  echo "[INFO] IAM policy already includes binding for $MEMBER"
fi
