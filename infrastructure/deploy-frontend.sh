#!/bin/bash
set -e

BUCKET="hajos-keepup-frontend-dev"
DISTRIBUTION_ID="$1"
FRONTEND_DIR="../../keepup-desktop"

if [ -z "$DISTRIBUTION_ID" ]; then
  echo "Usage: ./deploy-frontend.sh <cloudfront-distribution-id>"
  exit 1
fi

echo "Building frontend..."
cd "$FRONTEND_DIR"
npm run build -- --mode production

echo "Uploading to S3..."
aws s3 sync dist/ "s3://$BUCKET" --delete --region us-east-1

echo "Invalidating CloudFront cache..."
aws cloudfront create-invalidation \
  --distribution-id "$DISTRIBUTION_ID" \
  --paths "/*"

echo "Done. Live at https://keepup.hajos.app"
