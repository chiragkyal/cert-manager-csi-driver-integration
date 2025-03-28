terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws-region
}

resource "aws_s3_bucket" "s3-bucket" {
  bucket = var.bucket-name
}

resource "aws_iam_role_policy" "s3" {
  name = "ckyal-s3-full-access-policy"
  role = aws_iam_role.x509-role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*",
          "s3-object-lambda:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_rolesanywhere_trust_anchor" "x509-trust-anchor" {
  name    = "ckyal-x509-trust-anchor"
  enabled = true
  source {
    source_data {
      x509_certificate_data = file(var.root-CA)
    }
    source_type = "CERTIFICATE_BUNDLE"
  }
}

resource "aws_rolesanywhere_profile" "x509-profile" {
  name      = "ckyal-x509-profile"
  enabled   = true
  role_arns = [aws_iam_role.x509-role.arn]
}

resource "aws_iam_role" "x509-role" {
  name = "ckyal-x509-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["sts:AssumeRole", "sts:TagSession", "sts:SetSourceIdentity"]
        Effect = "Allow",
        Principal = {
          Service = "rolesanywhere.amazonaws.com",
        },
        Condition = {
          StringLike = {
            "aws:PrincipalTag/x509SAN/URI" = "${var.spiffe-id}",
          }
          ArnEquals = {
            "aws:SourceArn" = aws_rolesanywhere_trust_anchor.x509-trust-anchor.arn
          }
        }
      },
    ],
  })
}
