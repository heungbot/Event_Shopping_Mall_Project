# ECS Task가 target group으로 등록되지 않는 문제 발생
# + terraform code 이름 수정

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.VPC_CIDR
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.APP_NAME}-vpc"
    Environment = var.APP_ENV
  }
}

resource "aws_internet_gateway" "aws-igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "${var.APP_NAME}-igw"
    Environment = var.APP_ENV
  }
}

# EIP for NAT
resource "aws_eip" "nat-gw-ip" {
  count      = length(var.AZ)
  depends_on = [aws_internet_gateway.aws-igw]
}

resource "aws_nat_gateway" "aws-nat-gw" {
  count         = length(var.AZ)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.nat-gw-ip.*.id, count.index)
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.PUBLIC_CIDR, count.index)
  availability_zone       = element(var.AZ, count.index)
  count                   = length(var.PUBLIC_CIDR)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.APP_NAME}-public-subnet-${count.index + 1}"
    Environment = var.APP_ENV
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.PRIVATE_CIDR)
  cidr_block        = element(var.PRIVATE_CIDR, count.index)
  availability_zone = element(var.AZ, count.index)

  tags = {
    Name        = "${var.APP_NAME}-private-subnet-${count.index + 1}"
    Environment = var.APP_ENV
  }
}

resource "aws_subnet" "cache" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.CACHE_CIDR)
  cidr_block        = element(var.CACHE_CIDR, count.index)
  availability_zone = element(var.AZ, count.index)

  tags = {
    Name        = "${var.APP_NAME}-cache-subnet-${count.index + 1}"
    Environment = var.APP_ENV
  }
}

resource "aws_elasticache_subnet_group" "cache-subnet-group" {
  name       = "cache-subnet-group"
  subnet_ids = flatten(tolist(aws_subnet.cache.*.id))
}

resource "aws_subnet" "db" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.DB_CIDR)
  cidr_block        = element(var.DB_CIDR, count.index)
  availability_zone = element(var.AZ, count.index)

  tags = {
    Name        = "${var.APP_NAME}-db-subnet-${count.index + 1}"
    Environment = var.APP_ENV
  }
}

# public routing table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.APP_NAME}-routing-table-public"
    Environment = var.APP_ENV
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws-igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.PUBLIC_CIDR)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# private routing table
resource "aws_route_table" "private" {
  count  = length(var.AZ)
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.APP_NAME}-routing-table-private"
    Environment = var.APP_ENV
  }
}

resource "aws_route" "private" {
  count                  = length(aws_nat_gateway.aws-nat-gw.*.id)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_nat_gateway.aws-nat-gw.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(var.PRIVATE_CIDR)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

# DB SUBNET GROUP
resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = "rds_subnet_group"
  subnet_ids = flatten(tolist(aws_subnet.db.*.id))

  tags = {
    Name        = "${var.APP_NAME}-db-subnet-group"
    Environment = var.APP_ENV
  }
}