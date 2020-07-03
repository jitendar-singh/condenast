resource "aws_security_group" "web_sg"{
    name = "web_sg"
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