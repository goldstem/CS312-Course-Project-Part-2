provider "aws" {
	region = "us-east-1"
}

data "aws_ami" "ubuntu" {
	most_recent = true

	filter {
		name = "name"
		values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
	}

	owners = ["099720109477"] # Canonical
}

resource "aws_instance" "minecraft_server" {
	ami		= data.aws_ami.ubuntu.id
	instance_type	= "t2.small"

	vpc_security_group_ids = [aws_security_group.minecraft_server-sg.id]

	tags = {
		Name = "minecraft"
	}
}

resource "aws_security_group" "minecraft_server-sg" {
	name		= "minecraft_server-sg"
	description	= "sg for minecraft server"

	ingress {
		from_port	= 22
		to_port		= 22
		protocol	= "tcp"
		cidr_blocks	= ["0.0.0.0/0"]
	}

	ingress {
		from_port	= 25565
		to_port		= 25565
		protocol	= "tcp"
		cidr_blocks	= ["0.0.0.0/0"]
	}

	egress {
		from_port	= 0
		to_port		= 0
		protocol	= "-1"
		cidr_blocks	= ["0.0.0.0/0"]
	} 
} 
