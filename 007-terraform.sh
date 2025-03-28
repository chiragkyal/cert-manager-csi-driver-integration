#!/bin/bash

ROOT_DIR=$(pwd)

pushd terraform/ || exit 1

terraform init
terraform apply

# get terraform outputs and export them
terraform output -json | jq -r \
    '@sh "export AWS_ROLE_ARN=\(.role_arn.value)\nexport AWS_TRUST_ANCHOR_ARN=\(.trust_anchor_arn.value)\nexport AWS_PROFILE_ARN=\(.profile_arn.value)"' \
    >"$ROOT_DIR/env.sh"

popd || exit 1

# source the environment variables
source "$ROOT_DIR/env.sh"

# create aws config
cat <<EOF >aws.config
[profile use-roles-anywhere]
credential_process = aws_signing_helper credential-process --certificate /var/run/secrets/certificate/tls.crt --private-key /var/run/secrets/certificate/tls.key --profile-arn $AWS_PROFILE_ARN --trust-anchor-arn $AWS_TRUST_ANCHOR_ARN --role-arn $AWS_ROLE_ARN
EOF
