variable "bucket_name" {}
variable "s3_tag_name" {}

output "bucket_name" {
  value = aws_s3_bucket.srl_proj_dev_image_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.srl_proj_dev_image_bucket.arn
}

resource "aws_s3_bucket" "srl_proj_dev_image_bucket" {
    bucket = var.bucket_name

    tags = { Name    = var.s3_tag_name }
}