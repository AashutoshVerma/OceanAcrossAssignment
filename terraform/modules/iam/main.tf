locals {
  roles = ["company-role", "bureau-role", "employee-role"]
  prefixes = {
    "company-role"  = "company/"
    "bureau-role"   = "bureau/"
    "employee-role" = "employee/"
  }
}

resource "aws_iam_role" "roles" {
  for_each = toset(local.roles)
  name = "ocean-${each.key}-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = merge({ Name = "ocean-${each.key}" }, var.tags)
}

resource "aws_iam_policy" "s3_restrict" {
  for_each = toset(local.roles)
  name = "ocean-${each.key}-s3-policy-${var.environment}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${var.bucket_arn}/${local.prefixes[each.key]}*",
          "${var.bucket_arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  for_each = toset(local.roles)
  role       = aws_iam_role.roles[each.key].name
  policy_arn = aws_iam_policy.s3_restrict[each.key].arn
}

output "roles" {
  value = { for k, r in aws_iam_role.roles : k => r.name }
}
