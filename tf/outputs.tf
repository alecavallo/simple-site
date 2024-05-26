output "s3_bucket_arn" {
  value = aws_s3_bucket.website_bucket
}

output "cdn_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}
