variable "name" {}
variable "policy" {}
variable "identifier" {}

# IAMロール
resource "aws_iam_role" "default" {
    name = var.name
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


# 信頼ポリシー(自身をなんのサービスに関連付けるか宣言)
data "aws_iam_policy_document" "assume_role" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["var.identifier"]
        }
    }
}

# IAMポリシー
resource "aws_iam_policy" "default"{
    name = var.name
    policy = var.policy
}

# IAMポリシーとロールを紐付け(アタッチ)
resource "aws_iam_role_policy_attachment" "default {
    role = aws_iam_role.default.name
    rolicy_arn = aws_iam_policy.default.arn
}

output "iam_role_arn" {
  value = aws_iam_role.default.arn
}

output "iam_role_name" {
  value = aws_iam_role.default.name
}












