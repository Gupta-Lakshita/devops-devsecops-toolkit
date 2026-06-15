#main.tf
resource "local_file" "pet" {
  filename = var.filename[count.index]

  count = length(var.filename)
}

#variable.tf
variable "filename" {
  type=list(string)
  default = [
    "/root/pets.txt",
    "/root/dogs.txt",
    "/root/cats.txt"
  ]
}

#destroy and updates upon removing any item in list (index based)
#ouput as list too