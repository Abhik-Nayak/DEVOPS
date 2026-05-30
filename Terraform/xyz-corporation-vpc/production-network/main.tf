# =============================================================================
# PRODUCTION NETWORK - 4-Tier Architecture
# Tiers: Web (public) -> App1 -> App2 -> DBCache/DB (private)
# =============================================================================

# --- VPC ---
resource "aws_vpc" "production" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "production-vpc"
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "production_igw" {
  vpc_id = aws_vpc.production.id

  tags = {
    Name = "production-igw"
  }
}

# --- Elastic IP for NAT Gateway ---
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "production-nat-eip"
  }
}

# --- NAT Gateway (in public web subnet, used by dbcache and app1) ---
resource "aws_nat_gateway" "production_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.web.id

  tags = {
    Name = "production-nat-gw"
  }

  depends_on = [aws_internet_gateway.production_igw]
}

# =============================================================================
# SUBNETS
# =============================================================================

# Public subnet - Web
resource "aws_subnet" "web" {
  vpc_id                  = aws_vpc.production.id
  cidr_block              = var.web_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "production-web-subnet"
  }
}

# Private subnet - App1
resource "aws_subnet" "app1" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = var.app1_subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "production-app1-subnet"
  }
}

# Private subnet - App2
resource "aws_subnet" "app2" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = var.app2_subnet_cidr
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "production-app2-subnet"
  }
}

# Private subnet - DBCache
resource "aws_subnet" "dbcache" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = var.dbcache_subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "production-dbcache-subnet"
  }
}

# Private subnet - DB
resource "aws_subnet" "db" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = var.db_subnet_cidr
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "production-db-subnet"
  }
}

# =============================================================================
# ROUTE TABLES
# =============================================================================

# Public route table (for web subnet - full internet access)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.production.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.production_igw.id
  }

  tags = {
    Name = "production-public-rt"
  }
}

resource "aws_route_table_association" "web" {
  subnet_id      = aws_subnet.web.id
  route_table_id = aws_route_table.public.id
}

# Private route table with NAT (for app1 and dbcache - outbound internet only)
resource "aws_route_table" "private_nat" {
  vpc_id = aws_vpc.production.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.production_nat.id
  }

  tags = {
    Name = "production-private-nat-rt"
  }
}

resource "aws_route_table_association" "app1" {
  subnet_id      = aws_subnet.app1.id
  route_table_id = aws_route_table.private_nat.id
}

resource "aws_route_table_association" "dbcache" {
  subnet_id      = aws_subnet.dbcache.id
  route_table_id = aws_route_table.private_nat.id
}

# Private route table without NAT (for app2 and db - no internet access)
resource "aws_route_table" "private_isolated" {
  vpc_id = aws_vpc.production.id

  tags = {
    Name = "production-private-isolated-rt"
  }
}

resource "aws_route_table_association" "app2" {
  subnet_id      = aws_subnet.app2.id
  route_table_id = aws_route_table.private_isolated.id
}

resource "aws_route_table_association" "db" {
  subnet_id      = aws_subnet.db.id
  route_table_id = aws_route_table.private_isolated.id
}

# =============================================================================
# SECURITY GROUPS
# =============================================================================

# Web Security Group - allows HTTP/HTTPS from internet, SSH
resource "aws_security_group" "web_sg" {
  name        = "production-web-sg"
  description = "Security group for web tier"
  vpc_id      = aws_vpc.production.id

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
    Name = "production-web-sg"
  }
}

# App1 Security Group - allows traffic from web tier
resource "aws_security_group" "app1_sg" {
  name        = "production-app1-sg"
  description = "Security group for app1 tier"
  vpc_id      = aws_vpc.production.id

  ingress {
    description     = "App traffic from web tier"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
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
    Name = "production-app1-sg"
  }
}

# App2 Security Group - allows traffic from app1 tier
resource "aws_security_group" "app2_sg" {
  name        = "production-app2-sg"
  description = "Security group for app2 tier"
  vpc_id      = aws_vpc.production.id

  ingress {
    description     = "App traffic from app1 tier"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.app1_sg.id]
  }

  ingress {
    description     = "SSH from app1 tier"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.app1_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "production-app2-sg"
  }
}

# DBCache Security Group - allows cache traffic from app tiers
resource "aws_security_group" "dbcache_sg" {
  name        = "production-dbcache-sg"
  description = "Security group for dbcache tier"
  vpc_id      = aws_vpc.production.id

  ingress {
    description     = "Redis/Memcached from app1"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app1_sg.id]
  }

  ingress {
    description     = "Redis/Memcached from app2"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app2_sg.id]
  }

  ingress {
    description     = "SSH from app1"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.app1_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "production-dbcache-sg"
  }
}

# DB Security Group - allows DB traffic from app tiers and dbcache
resource "aws_security_group" "db_sg" {
  name        = "production-db-sg"
  description = "Security group for db tier"
  vpc_id      = aws_vpc.production.id

  ingress {
    description     = "MySQL from app1"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app1_sg.id]
  }

  ingress {
    description     = "MySQL from app2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app2_sg.id]
  }

  ingress {
    description     = "MySQL from dbcache"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.dbcache_sg.id]
  }

  ingress {
    description     = "SSH from app1"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.app1_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "production-db-sg"
  }
}

# =============================================================================
# NETWORK ACLs
# =============================================================================

# Web subnet NACL - allows HTTP/HTTPS/SSH inbound, ephemeral ports for return traffic
resource "aws_network_acl" "web_nacl" {
  vpc_id     = aws_vpc.production.id
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
    cidr_block = var.vpc_cidr
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    rule_no    = 140
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
    Name = "production-web-nacl"
  }
}

# App1 subnet NACL
resource "aws_network_acl" "app1_nacl" {
  vpc_id     = aws_vpc.production.id
  subnet_ids = [aws_subnet.app1.id]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.web_subnet_cidr
    from_port  = 8080
    to_port    = 8080
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.web_subnet_cidr
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 120
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
    Name = "production-app1-nacl"
  }
}

# App2 subnet NACL
resource "aws_network_acl" "app2_nacl" {
  vpc_id     = aws_vpc.production.id
  subnet_ids = [aws_subnet.app2.id]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.app1_subnet_cidr
    from_port  = 8080
    to_port    = 8080
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.app1_subnet_cidr
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr
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

  tags = {
    Name = "production-app2-nacl"
  }
}

# DBCache subnet NACL
resource "aws_network_acl" "dbcache_nacl" {
  vpc_id     = aws_vpc.production.id
  subnet_ids = [aws_subnet.dbcache.id]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.app1_subnet_cidr
    from_port  = 6379
    to_port    = 6379
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.app2_subnet_cidr
    from_port  = 6379
    to_port    = 6379
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.app1_subnet_cidr
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
    Name = "production-dbcache-nacl"
  }
}

# DB subnet NACL
resource "aws_network_acl" "db_nacl" {
  vpc_id     = aws_vpc.production.id
  subnet_ids = [aws_subnet.db.id]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.app1_subnet_cidr
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.app2_subnet_cidr
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.dbcache_subnet_cidr
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.app1_subnet_cidr
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 140
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr
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

  tags = {
    Name = "production-db-nacl"
  }
}

# =============================================================================
# EC2 INSTANCES (one per subnet, named after the subnet)
# =============================================================================

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.web.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "production-web"
  }
}

resource "aws_instance" "app1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.app1.id
  vpc_security_group_ids = [aws_security_group.app1_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "production-app1"
  }
}

resource "aws_instance" "app2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.app2.id
  vpc_security_group_ids = [aws_security_group.app2_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "production-app2"
  }
}

resource "aws_instance" "dbcache" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.dbcache.id
  vpc_security_group_ids = [aws_security_group.dbcache_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "production-dbcache"
  }
}

resource "aws_instance" "db" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.db.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "production-db"
  }
}
