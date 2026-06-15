variable "file-content" {
  type = map  #or map(string)

  default = {
    "statement1" = "We love pets!"
    "statement2" = "We love animals!"
  }
}

#in main
resource local_file my-pet {
  filename = "/root/pets.txt"
  content  = var.file-content["statement2"]
}