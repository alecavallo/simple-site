resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI for stoneitcloud.com bucket"
}

# cloudwatch logging and WAF are not required for this example
# tfsec:ignore:avd-aws-0010 tfsec:ignore:avd-aws-0011
resource "aws_cloudfront_distribution" "this" {
  origin {
    # domain_name = aws_s3_bucket_website_configuration.website_bucket_website_configuration.website_endpoint
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website_bucket.arn

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }

  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Cloudfront distribution for stoneitcloud.com"
  default_root_object = "index.html"
  aliases             = ["stoneitcloud.com"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.website_bucket.arn
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }



  price_class = "PriceClass_200"
  viewer_certificate {
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "CloudFront Origin Access Identity"
}
