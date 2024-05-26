output "s3_bucket_arn" {
  value       = aws_s3_bucket.website_bucket
  description = "origin s3 bucket object"
}

output "cdn_domain_name" {
  value       = aws_cloudfront_distribution.this.domain_name
  description = "CDN domain name"
}
