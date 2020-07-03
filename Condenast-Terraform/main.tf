resource "aws_iam_user" "main_user"{
    name = "Mainuser"
}
module "webmodule" {
    source = "./web"
    # web_ec2 = "web server"
    # web_sg = "web sg"
}
