#!/bin/bash
set -e

ENV="${1:-}"
DISTRIBUTION_ID="${2:-}"
FRONTEND_DIR="/Users/oliviamulhollandsalazar/Developer/hajos/keep-up/keepup-desktop"

if [ -z "$ENV" ] || [ -z "$DISTRIBUTION_ID" ]; then
  echo "Usage: ./deploy-frontend.sh <env> <cloudfront-distribution-id>"
  echo "  env: dev | staging | prod"
  exit 1
fi

case "$ENV" in
  dev)
    BUCKET="hajos-keepup-frontend-dev"
    VITE_MODE="dev"
    URL="https://dev-keepup.hajos.app"
    ;;
  staging)
    BUCKET="hajos-keepup-frontend-staging"
    VITE_MODE="staging"
    URL="https://staging-keepup.hajos.app"
    ;;
  prod)
    BUCKET="hajos-keepup-frontend-prod"
    VITE_MODE="production"
    URL="https://keepup.hajos.app"
    ;;
  *)
    echo "Unknown env: $ENV (must be dev, staging, or prod)"
    exit 1
    ;;
esac

echo "Building frontend for $ENV..."
cd "$FRONTEND_DIR"
npm run build -- --mode "$VITE_MODE"

echo "Uploading to s3://$BUCKET..."
aws s3 sync dist/ "s3://$BUCKET" --delete --region us-east-1

echo "Invalidating CloudFront cache..."
aws cloudfront create-invalidation \
  --distribution-id "$DISTRIBUTION_ID" \
  --paths "/*"

echo "Done. Live at $URL"
