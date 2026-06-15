#main.tf
resource "local_file" "pet" {
  filename = each.value

  for_each = toset(var.filename)
}

output "pets" {
  value = local_file.pet
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

#output as map
#key-value