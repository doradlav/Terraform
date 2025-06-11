provider "aws" {
  region = "us-east-1"
}

# Look up the already-existing security group by name
data "aws_security_group" "web_firewall" {
  filter {
    name   = "group-name"
    values = ["web_firewall"]
  }
}

resource "aws_instance" "web_file" {
  ami                    = "ami-0731becbf832f281e" # make sure you use ubuntu ami in that specific region
  instance_type          = "t2.micro"
  key_name               = "ec2-key"  # must match the AWS-imported key whose private key is at ~/.key.pem
  vpc_security_group_ids = [data.aws_security_group.web_firewall.id]

  # SSH connection settings
  connection {
    type        = "ssh"
    user        = "ubuntu"
   #private_key = file("~/key.pem")
    private_key = file("${path.module}/ec2-key.pem")
    host        = self.public_ip
  }

  # 1) copy the installer to the instance
  provisioner "file" {
    source      = "install_apache.sh"
    destination = "/tmp/install_apache.sh"
  }

  # 2) run it with sudo
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_apache.sh",
      "sudo bash /tmp/install_apache.sh"
    ]
  }

  tags = {
    Name = "terraform-file-prov"
  }
}
