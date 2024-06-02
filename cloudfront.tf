locals {
  s3_origin_id = "${local.service.website.name}_s3"
}

data "aws_s3_bucket" "website" {
  bucket = replace("${local.product_information.context.project}_${local.service.website.name}", "_", "-")
}

resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "S3 cloudfront origin access identity for ${local.service.website.title} service in ${local.projectTitle}"
}

resource "aws_cloudfront_response_headers_policy" "security_headers_policy" {
  name = "${replace(local.service.name, "_", "-")}-security-headers-policy"

  custom_headers_config {
    items {
      header   = "permissions-policy"
      override = true
      value    = "accelerometer=(), camera=(), geolocation=(self), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()"
    }
  }

  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "same-origin"
      override        = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
    strict_transport_security {
      access_control_max_age_sec = "63072000"
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
    content_security_policy {
      content_security_policy = "default-src 'self' ; font-src 'self' ; img-src 'self' ; object-src 'none'; script-src 'self' 'unsafe-inline' 'unsafe-eval' blob:; style-src 'self' 'unsafe-inline';"
      override                = true
    }
  }
}

resource "aws_cloudfront_function" "nextjs_add_html_file_extension" {
  name    = "${local.service.name}_nextjs_add_html_file_extension"
  runtime = "cloudfront-js-1.0"
  publish = true
  code    = file("${path.module}/cloudfront/add-html-file-extension.js")
}

resource "aws_cloudfront_distribution" "web_front_hosting" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  aliases = local.domainNames

  custom_error_response {
    error_caching_min_ttl = 7200
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  # S3 Origin
  origin {
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }

    domain_name = data.aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  # S3 by default
  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    default_ttl                = 7200
    min_ttl                    = 0
    max_ttl                    = 86400
    target_origin_id           = local.s3_origin_id
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers_policy.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.nextjs_add_html_file_extension.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn            = aws_acm_certificate.acm_certificate.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = local.tags
}

data "aws_iam_policy_document" "website_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.website.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.website.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [data.aws_s3_bucket.website.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.website.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = data.aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.website_s3_policy.json
}
