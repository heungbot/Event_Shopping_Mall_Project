provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

data "aws_acm_certificate" "heungbot_cert" { # data source가 가져오지 못하고 있음. 아마 acm cert가 eu-east-1 region에 존재해서 그런 것 같음.
  domain      = "*.heungbot.store"
  statuses    = ["ISSUED"]
  most_recent = true
  provider    = "aws.virginia"
  # 여기까지만 작성하면 acm cert를 찾지 못하고 있음
}

# 02 CloudFront
##### Cloudfront OAC setting #####
# bucket policy will changed in frontend-oac module
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "heungbot_oac"
  description                       = "oac for cnd - s3 bucket. s3 policy is located other module"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Cloudfront distribution for main s3 site.
resource "aws_cloudfront_distribution" "main_s3_distribution" {
  origin {
    domain_name              = var.MAIN_BUCKET_REGIONAL_DOMAIN_NAME # regional_domain_name = region이 포함된 bucket domain임. cf) bucket_domain_name = [bucketname.s3.amazonaws.com]
    origin_id                = "s3Main"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  # origin {
  #   domain_name              = var.ALB_DOMAIN # regional_domain_name = region이 포함된 bucket domain임. cf) bucket_domain_name = [bucketname.s3.amazonaws.com]
  #   origin_id                = "albMain"
  #   origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  # }

  # origin_group {
  #   origin_id = var.BUCKET_ORIGIN_GROUP_ID

  #   member {
  #     origin_id = "s3Main"
  #   }

  #   member {
  #     origin_id = "albMain"
  #   }

  #   failover_criteria {
  #     status_codes = [403, 404, 500, 502, 503, 504]
  #   }
  # }

  enabled         = true
  is_ipv6_enabled = true

  aliases      = ["www.${var.DOMAIN_NAME}"]
  http_version = "http2"                    // default = http2
  default_root_object = "index.html"

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/404.html"
  }

  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    # target_origin_id       = var.BUCKET_ORIGIN_GROUP_ID
    target_origin_id = "s3Main"
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.heungbot_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.FRONTEND_TAG
}

##### Route 53 #####
data "aws_route53_zone" "main" {
  name         = "${var.DOMAIN_NAME}." # data source = var.DOMAIN_NAME + "." 즉, 뒤에 .을 붙여줘야 하는가??
  private_zone = false
}

resource "aws_route53_record" "main-record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${var.DOMAIN_NAME}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.main_s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
