output "role_arn" {
  value = aws_iam_role.x509-role.arn
}

output "trust_anchor_arn" {
  value = aws_rolesanywhere_trust_anchor.x509-trust-anchor.arn
}

output "profile_arn" {
  value = aws_rolesanywhere_profile.x509-profile.arn
}
