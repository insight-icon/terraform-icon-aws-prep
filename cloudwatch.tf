variable "cloudwatch_enable" {
  description = "Enable CW"
  type        = bool
  default     = false
}

variable "logs_bucket_enable" {
  description = "Create bucket to put logs"
  type        = bool
  default     = false
}

variable "logging_bucket_name" {
  description = "Name of bucket for logs - blank for logs-<account-id>"
  type        = string
  default     = ""
}

resource "aws_s3_bucket" "logs" {
  count  = var.logs_bucket_enable && var.create ? 1 : 0
  bucket = local.logging_bucket_name
  acl    = "private"
  tags   = local.tags
}

data "aws_iam_policy_document" "cloudwatch_agent" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeTags",
      "cloudwatch:PutMetricData",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_agent" {
  count = var.cloudwatch_enable ? 1 : 0

  name = var.name

  role   = join("", aws_iam_role.this.*.id)
  policy = data.aws_iam_policy_document.cloudwatch_agent.json
}