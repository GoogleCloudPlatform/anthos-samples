/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

terraform {
  required_version = ">= 0.12.23"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  vpc_name      = "${var.anthos_prefix}-anthos-vpc"
  az_count      = length(var.subnet_availability_zones)
  psubnet_count = length(var.public_subnet_cidr_block)
}

# Create a VPC
# https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/how-to/create-aws-vpc

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.anthos_prefix}-anthos-vpc"
  }
}

# Create sample VPC
# https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/how-to/create-aws-vpc
# Create 4 private subnets and 1 public subnet.
# Three private subnets are used by the Anthos on AWS control planes (running in three zones)
# and one or more private subnets is used by node pools.
# The public subnets is used by the load balancers for associated services.

# Create 3 control plane subnets
# https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/how-to/create-aws-vpc
# Step 1
resource "aws_subnet" "private_cp" {
  count             = local.az_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.cp_private_subnet_cidr_blocks[count.index]
  availability_zone = var.subnet_availability_zones[count.index]
  tags = {
    Name                              = "${local.vpc_name}-private-cp-${var.subnet_availability_zones[count.index]}",
    "kubernetes.io/role/internal-elb" = "1"
  }
}


# Create a public subnet for each node pool
# Mark the subnet as public.
resource "aws_subnet" "public" {

  count                   = local.psubnet_count
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr_block[count.index]
  availability_zone       = var.subnet_availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.vpc_name}-public-${var.subnet_availability_zones[count.index]}"
  }
}


# Step 4
# Create an internet gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = local.vpc_name
  }
}



# Configure the routing table
# https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/how-to/create-aws-vpc#configure_the_routing_tables_for_private_subnets
# Step 1
resource "aws_route_table" "public" {
  count  = local.psubnet_count
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.vpc_name}-public-${count.index}"
  }
}

# Associate the public route table to the public subnet
resource "aws_route_table_association" "public" {

  count          = local.psubnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}


# Create default routers to the internet gateway
resource "aws_route" "public_internet_gateway" {
  count                  = local.psubnet_count
  route_table_id         = aws_route_table.public[count.index].id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
  timeouts {
    create = "5m"
  }
}


# Reservce an elastic IP address for the NAT gateway_id
resource "aws_eip" "nat" {
  count = local.psubnet_count
  vpc   = true
  tags = {
    Name = "${local.vpc_name}-nat-${var.subnet_availability_zones[count.index]}"
  }
}

# Create a Nat gateway for each of the public subnets
resource "aws_nat_gateway" "this" {
  count         = local.psubnet_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "${local.vpc_name}-${var.subnet_availability_zones[count.index]}"
  }
  depends_on = [aws_internet_gateway.this]
}

# Create a route table for each private subnet
resource "aws_route_table" "private" {
  count  = local.az_count
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.vpc_name}-private-${count.index}"
  }
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private" {
  count          = local.az_count
  subnet_id      = aws_subnet.private_cp[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
# Create default routes to the NAT gateway

resource "aws_route" "private_nat_gateway" {
  count                  = local.az_count
  route_table_id         = aws_route_table.private[count.index].id
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  timeouts {
    create = "5m"
  }
}
