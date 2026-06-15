#list but different data types allowed

variable "kitty" {
  type    = tuple([string, number, bool])
  default = ["cat", 7, true]
}