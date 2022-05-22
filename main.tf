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



# ネットワーク
# VPC
resource "aws_vpc" "example" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "example"
    }
}

# サブネット
resource "aws_subnet" "public" {
    vpc_id = aws_vpc.example.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true
    availability_zone = "ap-northeast-1a"
}

# GW
resource "aws_internet_gateway" "example" {
    vpc_id = aws_vpc.example.id
}

# routetable
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.example.id
}

# route ルートテーブルに記述するルート(インターネット向け)
resource "aws_route" "public" {
    route_table_id = aws_route_table.public.id
    gateway_id = aws_internet_gateway.example.id
    destination_cidr_block = "0.0.0.0/0"
}

# ルートテーブルとサブネットの紐付け
resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}




# プライベートサブネット
resource "aws_subnet" "private" {
    vpc_id = aws_vpc.example.id
    cidr_block = "10.0.64.0/24"
    availability_zone = "ap-northeast-1a"
    map_public_ip_on_launch = false # パブリックIPは不要
}

# routetable(private)
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.example.id
}

# ルートテーブルとプライベートサブネットの紐付け
resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}



# Elastic IP address
resource "aws_eip" "nat_gateway" {
    vpc = true
    depends_on = [aws_internet_gateway.example] # これを定義すると、指定したリソース作成後にこのリソースが作成開始される
}

# NAT
resource "aws_nat_gateway" "example" {
    allocation_id = aws_eip.nat_gateway.id
    subnet_id  = aws_subnet.public.id
    depends_on = [aws_internet_gateway.example]
}

# route ルートテーブルに記述するルート(privateからNATしてインターネット向け)
resource "aws_route" "private" {
    route_table_id = aws_route_table.private.id
    nat_gateway_id = aws_nat_gateway.example.id
    destination_cidr_block = "0.0.0.0/0"
}











