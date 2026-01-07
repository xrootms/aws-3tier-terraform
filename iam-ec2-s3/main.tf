variable "bucket_arn" {}
variable "role_name" {}


output "instance_profile_name" {
  value = aws_iam_instance_profile.role_on_EC2.name
}



resource "aws_iam_role" "ec2_role" {
    name = var.role_name

#Choose EC2
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }]
    })
}

#S3 Access Policy
resource "aws_iam_policy" "s3_policy" {
  name = "${var.role_name}-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = var.bucket_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${var.bucket_arn}/*"
      }
    ]
  })
}

#Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}


#Instance Profile (Use role on EC2)
resource "aws_iam_instance_profile" "role_on_EC2" {
  name = "${var.role_name}-profile"
  role = aws_iam_role.ec2_role.name
}



