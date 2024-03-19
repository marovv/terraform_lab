resource "aws_instance" "my_ec2" {
  instance_type = "t2.micro"
  ami = "ami-0f403e3180720dd7e"
  key_name = "newopenkey"
  vpc_security_group_ids = [aws_security_group.allow.id]
  tags = {
    Name = "NEWVM"
  }

provisioner "file" {
  source = "C:\\Users\\admin\\Desktop\\terra\\Day6\\readme.txt"
  destination = "/home/ec2-user/readme.txt"
}

provisioner "local-exec" {
  when = create
  command = "echo The server private IP address is ${self.private_ip}. The server public IP address is ${self.public_ip} > myec2ip.yaml"
}

provisioner "remote-exec" {
inline = [ 
    "echo my name is ${self.private_dns} >> /home/ec2-user/host_name.txt",
    "sudo yum check-update",
    "sudo yum -y update",
    "sudo yum install httpd -y",
    "sudo systemctl start httpd"
 ]  
}

connection {
  type = "ssh"
  user = "ec2-user"
  private_key = file("./newopenkey.pem")
  host = self.public_ip
}
}

resource "aws_security_group" "allow" {
  name = "allow SSH"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}