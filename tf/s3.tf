#S3 encryption is not required due the data on this bucket is publicly accessible
#tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-bucket-encryption tsec:ignore:aws-s3-encryption-customer-key tfsec:ignore:aws-s3-enable-versioning tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket" "website_bucket" {
  bucket = "stoneitcloud.com"
}
resource "aws_s3_bucket_public_access_block" "website_bucket_acl" {
  bucket                  = aws_s3_bucket.website_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "stoneit_key" {
  description             = "This key is used to encrypt bucket objects for corporate site"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}
data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "kms_key_policy_document" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${tostring(data.aws_caller_identity.current.account_id)}:root"]
    }
  }

  statement {
    sid    = "Allow CloudWatch Logs to use the key"
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${tostring(data.aws_caller_identity.current.account_id)}:root"]
    }
  }
}
resource "aws_kms_key_policy" "stoneit_key_policy" {
  key_id = aws_kms_key.stoneit_key.key_id
  policy = data.aws_iam_policy_document.kms_key_policy_document.json
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
resource "aws_s3_object" "dist" {
  for_each = fileset("./example-website-code", "*")
  bucket   = aws_s3_bucket.website_bucket.id
  key      = each.value
  source   = "./example-website-code/${each.value}"
  # update files when they changes
  etag = filemd5("./example-website-code/${each.value}")
}
