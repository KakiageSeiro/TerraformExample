module "web_server" {
    source = "./http_server"
    instance_type = "t3.micro"
}

output "public_dns" {
    value = module.web_server.public_dns
}




module "describe_regions_for_ec2" {
    source = "./iam_role"

    # 以下は必要な変数
    name = "describe-regions-for-ec2"
    identifier = "ec2.amazonaws.com"
    policy = data.aws_iam_policy_document.allow_describe_regions.json
}


# リージョン一覧を取得する権限のポリシードキュメント
data "aws_iam_policy_document" "allow_describe_regions" {
    statement {
        effect = "Allow"
        actions = ["ec2:DescribeRegions"] # リージョン一覧を取得する
        resources = ["*"]
    }
}
