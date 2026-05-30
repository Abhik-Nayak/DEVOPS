# =============================================================================
# DEVELOPMENT NETWORK - 2-Tier Architecture
# Tiers: Web (public) -> DB (private)
# Peered with Production Network (db-to-db connectivity)
# =============================================================================

# --- VPC ---
resource "aws_vpc" "development" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "development-vpc"
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "development_igw" {
  vpc_id = aws_vpc.development.id

  tags = {
    Name = "development-igw"
  }
}

# =============================================================================
# SUBNETS
# =============================================================================

# Public subnet - Web
resource "aws_subnet" "web" {
  vpc_id                  = aws_vpc.development.id
  cidr_block              = var.web_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "development-web-subnet"
  }
}

# Private subnet - DB
resource "aws_subnet" "db" {
  vpc_id            = aws_vpc.development.id
  cidr_block        = var.db_subnet_cidr
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "development-db-subnet"
  }
}

# =============================================================================
# ROUTE TABLES
# =============================================================================

# Public route table (web subnet - internet access via IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.development.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.development_igw.id
  }

  tags = {
    Name = "development-public-rt"
  }
}

resource "aws_route_table_association" "web" {
  subnet_id      = aws_subnet.web.id
  route_table_id = aws_route_table.public.id
}

# Private route table (db subnet - no internet, but route to production via peering)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.development.id

  tags = {
    Name = "development-private-rt"
  }
}

resource "aws_route_table_association" "db" {
  subnet_id      = aws_subnet.db.id
  route_table_id = aws_route_table.private.id
}

# =============================================================================
# SECURITY GROUPS
# =============================================================================

# Web Security Group - allows HTTP/HTTPS/SSH from internet
resource "aws_security_group" "web_sg" {
  name        = "development-web-sg"
  description = "Security group for development web tier"
  vpc_id      = aws_vpc.development.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "development-web-sg"
  }
}

# DB Security Group - allows DB traffic from web tier and production DB subnet
resource "aws_security_group" "db_sg" {
  name        = "development-db-sg"
  description = "Security group for development db tier"
  vpc_id      = aws_vpc.development.id

  ingress {
    description     = "MySQL from web tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    description = "MySQL from production DB subnet (via peering)"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.production_db_subnet_cidr]
  }

  ingress {
    description     = "SSH from web tier"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "development-db-sg"
  }
}

# =============================================================================
# NETWORK ACLs
# =============================================================================

# Web subnet NACL
resource "aws_network_acl" "web_nacl" {
  vpc_id     = aws_vpc.development.id
  subnet_ids = [aws_subnet.web.id]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "development-web-nacl"
  }
}

# DB subnet NACL - allows DB traffic from web subnet and production DB subnet via peering
resource "aws_network_acl" "db_nacl" {
  vpc_id     = aws_vpc.development.id
  subnet_ids = [aws_subnet.db.id]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.web_subnet_cidr
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.production_db_subnet_cidr
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.web_subnet_cidr
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    rule_no    = 140
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.production_db_subnet_cidr
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 65535
  }

  egress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.production_db_subnet_cidr
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "development-db-nacl"
  }
}

# =============================================================================
# EC2 INSTANCES
# =============================================================================

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.web.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "development-web"
  }
}

resource "aws_instance" "db" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.db.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "development-db"
  }
}

# =============================================================================
# VPC PEERING - Production <-> Development
# =============================================================================

resource "aws_vpc_peering_connection" "prod_dev" {
  vpc_id      = aws_vpc.development.id
  peer_vpc_id = var.production_vpc_id
  auto_accept = true

  tags = {
    Name = "production-development-peering"
  }
}

# Route from development DB subnet to production VPC via peering
resource "aws_route" "dev_db_to_prod" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = var.production_db_subnet_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.prod_dev.id
}

# Route from production DB subnet to development VPC via peering
resource "aws_route" "prod_db_to_dev" {
  route_table_id            = var.production_db_route_table_id
  destination_cidr_block    = var.db_subnet_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.prod_dev.id
}
