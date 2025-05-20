# VPC1 생성
resource "aws_vpc" "vpc1" {
  cidr_block           = "10.70.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "AWS-VPC1"
  }
}
# 인터넷 게이트웨이 1 생성 및 VPC1에 연결
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "AWS-IGW1"
  }
}
# 라우트 테이블 1 생성
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "AWS-PublicRT"
  }
}
# 기본 라우트 설정 (0.0.0.0/0 -> IGW1)
resource "aws_route" "default_route1" {
  route_table_id         = aws_route_table.rt1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw1.id
}
# 서브넷 1 생성
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.70.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "AWS-VPC1-Subnet1"
  }
}
# 서브넷 1과 라우트 테이블 1 연계
resource "aws_route_table_association" "rta_subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}
# 서브넷 2 생성
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.70.2.0/24"
  availability_zone       = "ap-northeast-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "AWS-VPC1-Subnet2"
  }
}
# 서브넷 2와 라우트 테이블 1 연계
resource "aws_route_table_association" "rta_subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt1.id
}
# VPC2 생성
resource "aws_vpc" "vpc2" {
  cidr_block           = "10.80.0.0/16"
  enable_dns_support   = false
  enable_dns_hostnames = false
  tags = {
    Name = "IDC-VPC2"
  }
}
# 인터넷 게이트웨이 2 생성 및 VPC2에 연결
resource "aws_internet_gateway" "igw2" {
  vpc_id = aws_vpc.vpc2.id
  tags = {
    Name = "IDC-IGW2"
  }
}
# 라우트 테이블 3 생성
resource "aws_route_table" "rt3" {
  vpc_id = aws_vpc.vpc2.id
  tags = {
    Name = "IDC-PublicRT"
  }
}
# 기본 라우트 설정 (0.0.0.0/0 -> IGW2)
resource "aws_route" "default_route3" {
  route_table_id         = aws_route_table.rt3.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw2.id
}
# 서브넷 3 생성
resource "aws_subnet" "subnet3" {
  vpc_id                  = aws_vpc.vpc2.id
  cidr_block              = "10.80.1.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "IDC-VPC2-Subnet"
  }
}
# 서브넷 3과 라우트 테이블 3 연계
resource "aws_route_table_association" "rta_subnet3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.rt3.id
}
# VPC 피어링 설정
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id        = aws_vpc.vpc1.id
  peer_vpc_id   = aws_vpc.vpc2.id
  peer_region   = "ap-northeast-2"
  tags = {
    Name = "VPCPeering"
  }
}
# VPC1에서 VPC2로의 라우트 설정
resource "aws_route" "peering_route1" {
  route_table_id             = aws_route_table.rt1.id
  destination_cidr_block     = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.vpc_peering.id
}
# VPC2에서 VPC1로의 라우트 설정
resource "aws_route" "peering_route2" {
  route_table_id             = aws_route_table.rt3.id
  destination_cidr_block     = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.vpc_peering.id
}