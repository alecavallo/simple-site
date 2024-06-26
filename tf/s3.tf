#S3 encryption is not required due the data on this bucket is publicly accessible
# tfsec:ignore:avd-aws-0088 tfsec:ignore:avd-aws-0089 tfsec:ignore:avd-aws-0090 tfsec:ignore:avd-aws-0132 tfsec:ignore:avd-aws-0320
resource "aws_s3_bucket" "website_bucket" {
  bucket = local.bucket_name
}
resource "aws_s3_bucket_public_access_block" "website_bucket_acl" {
  bucket                  = aws_s3_bucket.website_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "website_bucket_website_configuration" {
  bucket = aws_s3_bucket.website_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

data "aws_iam_policy_document" "website_bucket_policy_document" {
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = [aws_s3_bucket.website_bucket.arn, "${aws_s3_bucket.website_bucket.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
  statement {
    sid    = "AllowCloudFrontOriginAccessIdentity"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
    actions   = ["s3:GetObject"]
    resources = [aws_s3_bucket.website_bucket.arn, "${aws_s3_bucket.website_bucket.arn}/*"]
  }
}
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.website_bucket_policy_document.json
}


/*UPLOADING EXAMPLE WEBSITE*/
# this is not the ideal way to deploy code into S3. This was created to show how the static site will work
resource "aws_s3_object" "dist" {
  for_each     = fileset("./example-website-code", "**")
  bucket       = aws_s3_bucket.website_bucket.id
  key          = each.value
  source       = "./example-website-code/${each.value}"
  content_type = lookup(local.content_type_map, reverse(split(".", "./example-website-code/${each.value}"))[0], "text/html")
  # update files when they changes
  etag = filemd5("./example-website-code/${each.value}")
}
