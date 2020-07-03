resource "aws_eip" "web_eip"{
    instance = "${aws_instance.web_ec2.id}"

    tags = {
        Name = "helloworld"
    }
}
output "web_public_ip"{
    value = "${aws_eip.web_eip.public_ip}"
}
