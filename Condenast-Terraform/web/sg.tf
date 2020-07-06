resource "aws_security_group" "web_sg"{
    name = "web_sg"
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
    ingress{
        to_port = 8000
        from_port = 8000
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress{
        to_port = 8000
        from_port = 8000
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

}
