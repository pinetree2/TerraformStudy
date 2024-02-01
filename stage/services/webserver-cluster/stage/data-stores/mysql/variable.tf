variable "db_username" {
 description = "The username for the database"
 type = string
 sensitive = true
 default = "test1234"
}

variable "db_password" {
 description = "The password for the database"
 type = string
 sensitive = true
 default = "test1234"

}