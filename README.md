# cert-manager-csi-driver-integration

Integrate cert-manager with csi-driver

References
- https://cert-manager.io/docs/configuration/vault/
- https://cert-manager.io/docs/usage/csi/
- https://developer.hashicorp.com/vault/api-docs/auth/kubernetes
- https://developer.hashicorp.com/vault/docs/secrets/pki/setup
- https://cert-manager.io/docs/configuration/vault/#c-authenticating-with-kubernetes-service-accounts
- https://developer.hashicorp.com/vault/docs/auth/kubernetes



# AWS Role Anywhere

## Establish Trust
https://docs.aws.amazon.com/rolesanywhere/latest/userguide/getting-started.html

## Upload the Root CA and create a trust anchor
https://us-east-2.console.aws.amazon.com/rolesanywhere/home/?region=us-east-2


## Configure Role
https://docs.aws.amazon.com/rolesanywhere/latest/userguide/getting-started.html#getting-started-step2

- Select "Custom Trust Policy"

```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Service": [
					"rolesanywhere.amazonaws.com"
				]
			},
			"Action": [
				"sts:AssumeRole",
				"sts:TagSession",
				"sts:SetSourceIdentity"
			],
			"Condition": {
				"ArnEquals": {
					"aws:SourceArn": [
						"arn:aws:rolesanywhere:us-east-2:269733383066:trust-anchor/<ARN>"
					]
				},
				"StringLike": {
                    "aws:PrincipalTag/x509SAN/URI": "spiffe://example.com/ns/sandbox/pod/workload"
                }
			}
		}
	]
}
```
- Change the trust-anchor ARN and SVID
- Select Permissions policy: AmazonS3FullAccess, AmazonEC2ReadOnlyAccess

## Create a Profile and use the IAM Role
https://docs.aws.amazon.com/rolesanywhere/latest/userguide/getting-started.html#getting-started-step2


## Authenticate

Add the following to your `~/.aws/config` file inside pod:

```bash
[profile use-roles-anywhere]
credential_process = aws_signing_helper credential-process --certificate /var/run/secrets/certificate/tls.crt --private-key /var/run/secrets/certificate/tls.key --profile-arn $PROFILE_ARN --trust-anchor-arn $TRUST_ANCHOR_ARN --role-arn $ROLE_ARN
```

> Replace $PROFILE_ARN, $TRUST_ANCHOR_ARN, and $ROLE_ARN with the ARNs of the profile, trust anchor, and role you created in the previous steps.

### Run S3 commands
`aws --profile use-roles-anywhere s3 ls`
