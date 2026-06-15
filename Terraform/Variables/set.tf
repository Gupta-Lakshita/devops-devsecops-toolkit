#list but no duplicate values

variable "prefix" {
  default = ["Mr", "Mrs", "Sir"]
  type    = set  #or set(string)
}