// VPC module: creates VPC, public/private subnets (2 AZs), IGW, NAT Gateways, routes
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = merge({ Name = "ocean-across-${var.tags.environment}-vpc" }, var.tags)
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "ocean-across-igw" }
}

// Public subnets
resource "aws_subnet" "public" {
  for_each            = { for idx, cidr in var.public_subnets : idx => cidr }
  vpc_id              = aws_vpc.this.id
  cidr_block          = each.value
  map_public_ip_on_launch = true
  tags = merge({ Name = "ocean-across-public-${each.key}" }, var.tags)
}

// Private subnets
resource "aws_subnet" "private" {
  for_each          = { for idx, cidr in var.private_subnets : idx => cidr }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  tags = merge({ Name = "ocean-across-private-${each.key}" }, var.tags)
}

// Elastic IPs for NATs (one per private subnet)
resource "aws_eip" "nat" {
  for_each = aws_subnet.private
}

resource "aws_nat_gateway" "nat" {
  for_each     = aws_subnet.private
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  tags = { Name = "ocean-across-nat-${each.key}" }
}

// Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each    = aws_subnet.public
  subnet_id   = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "private_to_nat" {
  for_each = aws_nat_gateway.nat
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = each.value.id
}

resource "aws_route_table_association" "private_assoc" {
  for_each    = aws_subnet.private
  subnet_id   = each.value.id
  route_table_id = aws_route_table.private.id
}
