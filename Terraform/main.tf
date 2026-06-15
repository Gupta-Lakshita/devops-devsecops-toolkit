resource "local_file" "pet" {
  filename = "/root/pets.txt"
  content  = "We love pets!"
}

resource "local_file" "cat" {
  filename = "/root/cat.txt"
  content  = "My favorite pet is Mr. Whiskers"
}

resource "random_pet" "my-pet" {
  prefix    = "Mrs"
  separator = "."
  length    = "1"
}

// terraform init
// terraform plan
// terraform apply