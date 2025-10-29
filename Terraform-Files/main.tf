resource "aws_instance" "myinstance" {
  tags = {
    Name = "TF-Server"
  }
  ami = "ami-07860a2d7eb515d9a"
  instance_type = "t3.micro"
  key_name = "Gkp"
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  root_block_device {
    volume_size = 20
  }
}