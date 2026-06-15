#1
resource "local_file" "pet" {
  filename        = "/root/pets.txt"
  content         = "We love pets!"
  file_permission = "0700"

  lifecycle {
    create_before_destroy = true
  }
}

#2
resource "local_file" "pet" {
  filename        = "/root/pets.txt"
  content         = "We love pets!"
  file_permission = "0700"

  lifecycle {
    prevent_destroy = true
  }
}

#3
resource "aws_instance" "webserver" {
  ami           = "ami-0edab43b6fa892279"
  instance_type = "t2.micro"

  tags = {
    Name = "ProjectA-Webserver"
  }

  lifecycle {
    ignore_changes = [
      tags,
      ami
    ]
#or
  lifecycle {
    ignore_changes = all
  
  }
}