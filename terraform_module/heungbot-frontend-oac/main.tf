data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions = [ "s3:GetObject" ]
    resources = [ "${var.MAIN_BUCKET_ARN}/*" ]
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [var.MAIN_CLOUDFRONT_ARN]
    }
  }
}

resource "aws_s3_bucket_policy" "cdn-oac-bucket-policy" {
    bucket = var.MAIN_BUCKET_ID
    policy = data.aws_iam_policy_document.s3_bucket_policy.json
}