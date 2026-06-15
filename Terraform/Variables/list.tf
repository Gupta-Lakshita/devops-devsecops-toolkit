variable "prefix" {
  default = ["Mr", "Mrs", "Sir"]
  type    = list  #or list(string)
}

#in main
resource "random_pet" "my-pet" {
  prefix = var.prefix[0]
}

