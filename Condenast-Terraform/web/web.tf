resource "aws_instance" "web_ec2"{
    ami = "ami-0a63f96e85105c6d3"
    instance_type = "t2.large"
    security_groups = ["${aws_security_group.web_sg.name}"]
    user_data = "${file("./web/server-script.sh")}"
}