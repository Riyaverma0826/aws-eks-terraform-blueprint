#############################################
# 🌐 AWS VPC + Subnets + Routing
#############################################

# Get all available Availability Zones
data "aws_availability_zones" "available" {}

# Create VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = var.vpc_name
  })
}

# Create Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.vpc_public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.vpc_public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                         = "${var.vpc_name}-public-${count.index + 1}"
    "kubernetes.io/role/elb"     = 1
    "kubernetes.io/cluster/${var.vpc_name}" = "shared"
  })
}

# Create Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.vpc_private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.vpc_private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name                                 = "${var.vpc_name}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb"    = 1
    "kubernetes.io/cluster/${var.vpc_name}" = "shared"
  })
}

# Create Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-igw"
  })
}

# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-public-rt"
  })
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create NAT Gateway (Optional)
resource "aws_eip" "nat" {
  count = var.vpc_enable_nat_gateway ? 1 : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  count         = var.vpc_enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-nat"
  })
}

# Create Private Route Table
resource "aws_route_table" "private" {
  count  = var.vpc_enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[0].id
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-private-rt"
  })
}

# Associate Private Subnets with Route Table
resource "aws_route_table_association" "private_assoc" {
  count          = var.vpc_enable_nat_gateway ? length(aws_subnet.private[*].id) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

