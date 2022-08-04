resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true" #gives you an internal domain name
    enable_dns_hostnames = "true" #gives you an internal host name
    enable_classiclink = "false"
    instance_tenancy = "default"    
    
    tags = {
        Name = "prod-vpc"
    }
}


resource "aws_internet_gateway" "internet-gateway" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags = {
        Name = "prod-igw"
    }
}

resource "aws_subnet" "public-subnet-1" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "us-west-2a"
    tags = {
        Name = "public-subnet-1"
    }
}



resource "aws_route_table" "public-route-table" {
    vpc_id = "${aws_vpc.vpc.id}"
    
    route  {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.internet-gateway.id}" 
    }
    
    tags = {
        Name = "public-route-table"
    }
}


resource "aws_route_table_association" "route-table-subnets-associated"{
    subnet_id = "${aws_subnet.public-subnet-1.id}"
    route_table_id = "${aws_route_table.public-route-table.id}"
}


resource "aws_security_group" "ssh-http-sg" {
    vpc_id = "${aws_vpc.vpc.id}"
    
    egress  {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress  {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        // This means, all ip address are allowed to ssh ! 
        // Do not do it in the production. 
        // Put your office or home address in it!
        cidr_blocks = ["0.0.0.0/0"]
    }
    //If you do not add this rule, you can not reach the NGIX  
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "ssh-http-sg"
    }
}
