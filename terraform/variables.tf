variable "bucket-name" {
  default = "ckyal-s3-bucket"
}

variable "spiffe-id" {
  default = "spiffe://example.com/ns/sandbox/pod/workload"
}

variable "aws-region" {
  default = "us-east-2"
}

variable "root-CA" {
  default = "../ca.crt"
}
